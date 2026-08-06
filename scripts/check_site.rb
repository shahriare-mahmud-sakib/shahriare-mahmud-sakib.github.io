#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "pathname"
require "set"
require "date"

ROOT = Pathname.new(__dir__).parent
errors = []
warnings = []

def relative(path)
  path.relative_path_from(ROOT).to_s
end

def syntax_check_yaml(path, errors)
  text = path.read(encoding: "UTF-8")

  if text.include?("\t")
    errors << "#{relative(path)}: contains TAB characters; YAML indentation must use spaces."
    return
  end

  begin
    Psych.parse(text, filename: relative(path))
  rescue Psych::SyntaxError => e
    errors << "#{relative(path)}: line #{e.line}, column #{e.column}: #{e.problem}"
  rescue StandardError => e
    errors << "#{relative(path)}: #{e.class}: #{e.message}"
  end
end

def front_matter(path)
  text = path.read(encoding: "UTF-8")
  match = text.match(/\A---\s*\n(.*?)\n---\s*(?:\n|\z)/m)
  return nil unless match

  YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true) || {}
rescue Psych::SyntaxError => e
  raise Psych::SyntaxError.new(
    path.to_s,
    e.line,
    e.column,
    e.offset,
    e.problem,
    e.context
  )
end

# ---------------------------------------------------------------------------
# 1. Validate _config.yml and every YAML data file.
# ---------------------------------------------------------------------------
yaml_files = [ROOT.join("_config.yml")] +
             Dir.glob(ROOT.join("_data/**/*.{yml,yaml}")).map { |p| Pathname.new(p) }

yaml_files.sort.each do |path|
  syntax_check_yaml(path, errors)
end

# Reject common accidental browser/Windows duplicate filenames.
data_files = Dir.glob(ROOT.join("_data/*.{yml,yaml}")).map { |p| Pathname.new(p) }

data_files.each do |path|
  name = path.basename.to_s
  if name.match?(/\(\d+\)|\bcopy\b/i)
    errors << "#{relative(path)}: looks like an accidental duplicate data file."
  end
end

normalised = data_files.group_by do |path|
  path.basename.to_s
      .downcase
      .sub(/\s*\(\d+\)(?=\.(ya?ml)\z)/, "")
      .sub(/\s+copy(?=\.(ya?ml)\z)/, "")
end

normalised.each_value do |paths|
  next if paths.length == 1
  errors << "Possible duplicate YAML files: #{paths.map { |p| relative(p) }.join(', ')}"
end

# Stop route checking if basic YAML parsing already failed.
unless errors.empty?
  warn "SITE VALIDATION FAILED"
  warn "======================"
  errors.each { |error| warn "- #{error}" }
  exit 1
end

# ---------------------------------------------------------------------------
# 2. Validate front matter and collect permalinks.
# ---------------------------------------------------------------------------
content_patterns = [
  "_pages/**/*.{md,markdown,html}",
  "_portfolio/**/*.{md,markdown,html}",
  "_publications/**/*.{md,markdown,html}",
  "_teaching/**/*.{md,markdown,html}",
  "_talks/**/*.{md,markdown,html}",
  "_posts/**/*.{md,markdown,html}"
]

content_files = content_patterns.flat_map do |pattern|
  Dir.glob(ROOT.join(pattern)).map { |p| Pathname.new(p) }
end.uniq.sort

permalink_to_files = Hash.new { |hash, key| hash[key] = [] }
front_matter_records = []

content_files.each do |path|
  begin
    fm = front_matter(path)
  rescue Psych::SyntaxError => e
    errors << "#{relative(path)}: invalid front matter near line #{e.line}: #{e.problem}"
    next
  end

  next unless fm

  permalink = fm["permalink"].to_s
  permalink_to_files[permalink] << relative(path) unless permalink.empty?

  front_matter_records << {
    path: relative(path),
    layout: fm["layout"].to_s,
    permalink: permalink,
    research_type: fm["research_type"].to_s,
    research_slug: fm["research_slug"].to_s
  }
end

permalink_to_files.each do |permalink, files|
  next if files.length == 1
  warnings << "Duplicate permalink #{permalink.inspect}: #{files.join(', ')}"
end

# ---------------------------------------------------------------------------
# 3. Confirm that the Activities page actually consumes activities.yml.
# ---------------------------------------------------------------------------
activities_page = ROOT.join("_pages/year-archive.html")

unless activities_page.file?
  errors << "Missing _pages/year-archive.html"
else
  activities_page_text = activities_page.read(encoding: "UTF-8")

  unless activities_page_text.include?("site.data.activities")
    errors << "_pages/year-archive.html does not read _data/activities.yml."
  end

  unless activities_page_text.include?('title: "Activities"')
    errors << "_pages/year-archive.html is still configured as the sample Blog posts page."
  end
end

# ---------------------------------------------------------------------------
# 4. Validate internal Activity detail links.
# ---------------------------------------------------------------------------
activities_data = YAML.safe_load(ROOT.join("_data/activities.yml").read, permitted_classes: [Date, Time], aliases: true) || {}
permalinks = permalink_to_files.keys.to_set

Array(activities_data.dig("sections")).each { |_unused| } # keeps Ruby 3.2 syntax simple

sections = activities_data["sections"] || {}
sections.each_value do |section|
  Array(section["items"]).each do |item|
    next unless item["linked"]

    url = item["url"].to_s
    next if url.empty?
    next if url.start_with?("http://", "https://")

    path_only = url.split("#", 2).first
    unless permalinks.include?(path_only)
      errors << "_data/activities.yml: #{item['title'].inspect} links to #{url.inspect}, but no matching page permalink exists."
    end
  end
end

# ---------------------------------------------------------------------------
# 5. Validate Research detail URLs, slugs, and layouts when present.
# ---------------------------------------------------------------------------
research_file = ROOT.join("_data/research_page.yml")

if research_file.file?
  research = YAML.safe_load(research_file.read, permitted_classes: [Date, Time], aliases: true) || {}

  {
    "completed" => research.dig("completed_research", "items"),
    "current" => research.dig("current_research", "items")
  }.each do |research_type, items|
    Array(items).each do |item|
      slug = item["slug"].to_s
      detail_url = item["detail_url"].to_s

      matches = front_matter_records.select do |record|
        record[:layout] == "research-detail" &&
          record[:research_type] == research_type &&
          record[:research_slug] == slug
      end

      if matches.empty?
        errors << "Research item #{research_type}/#{slug}: matching research-detail page is missing."
        next
      end

      matches.each do |record|
        if record[:permalink] != detail_url
          errors << "#{record[:path]}: permalink #{record[:permalink].inspect} does not match detail_url #{detail_url.inspect}."
        end
      end
    end
  end

  unless ROOT.join("_layouts/research-detail.html").file?
    errors << "Missing _layouts/research-detail.html"
  end
end

# ---------------------------------------------------------------------------
# Result.
# ---------------------------------------------------------------------------
if errors.empty?
  puts "All YAML, front matter, Activities routes, and Research routes are valid."
  warnings.each { |warning| warn "Warning: #{warning}" }
  exit 0
end

warn "SITE VALIDATION FAILED"
warn "======================"
errors.each { |error| warn "- #{error}" }
exit 1
