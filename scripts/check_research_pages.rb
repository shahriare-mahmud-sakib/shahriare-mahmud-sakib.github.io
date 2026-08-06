#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "pathname"

ROOT = Pathname.new(__dir__).parent
DATA_FILE = ROOT.join("_data/research_page.yml")
LAYOUT_FILE = ROOT.join("_layouts/research-detail.html")
PAGE_ROOT = ROOT.join("_pages/research")

errors = []

unless DATA_FILE.file?
  errors << "Missing #{DATA_FILE.relative_path_from(ROOT)}"
end

unless LAYOUT_FILE.file?
  errors << "Missing #{LAYOUT_FILE.relative_path_from(ROOT)}"
end

def read_front_matter(path)
  text = path.read(encoding: "UTF-8")
  match = text.match(/\A---\s*\n(.*?)\n---\s*(?:\n|\z)/m)
  return nil unless match

  YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true) || {}
end

if DATA_FILE.file?
  begin
    data = YAML.safe_load(DATA_FILE.read(encoding: "UTF-8"), aliases: true) || {}
  rescue Psych::SyntaxError => e
    errors << "#{DATA_FILE.relative_path_from(ROOT)}: YAML error at line #{e.line}: #{e.problem}"
    data = {}
  end

  configured = []

  {
    "completed" => data.dig("completed_research", "items"),
    "current" => data.dig("current_research", "items")
  }.each do |research_type, items|
    Array(items).each do |item|
      slug = item["slug"].to_s
      url = item["detail_url"].to_s

      if slug.empty?
        errors << "#{research_type} research item is missing slug"
        next
      end

      if url.empty?
        errors << "#{research_type}/#{slug}: missing detail_url"
      end

      configured << {
        "type" => research_type,
        "slug" => slug,
        "url" => url
      }
    end
  end

  pages = Dir.glob(PAGE_ROOT.join("**/*.md")).map { |p| Pathname.new(p) }

  page_records = pages.filter_map do |page|
    fm = read_front_matter(page)
    next unless fm
    next unless fm["layout"] == "research-detail"

    {
      "path" => page.relative_path_from(ROOT).to_s,
      "type" => fm["research_type"].to_s,
      "slug" => fm["research_slug"].to_s,
      "url" => fm["permalink"].to_s
    }
  end

  configured.each do |item|
    matches = page_records.select do |page|
      page["type"] == item["type"] && page["slug"] == item["slug"]
    end

    if matches.empty?
      errors << "#{item['type']}/#{item['slug']}: no matching detail page found"
      next
    end

    if matches.length > 1
      errors << "#{item['type']}/#{item['slug']}: multiple matching detail pages found"
    end

    matches.each do |page|
      if page["url"] != item["url"]
        errors << "#{page['path']}: permalink #{page['url'].inspect} does not match detail_url #{item['url'].inspect}"
      end
    end
  end

  page_records.each do |page|
    exists = configured.any? do |item|
      item["type"] == page["type"] && item["slug"] == page["slug"]
    end

    unless exists
      errors << "#{page['path']}: no matching YAML research item"
    end
  end
end

if errors.empty?
  puts "Research detail-page check passed."
  exit 0
end

warn "RESEARCH DETAIL-PAGE CHECK FAILED"
warn "================================="
errors.each { |error| warn "- #{error}" }
exit 1
