#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "pathname"

ROOT = Pathname.new(__dir__).parent

yaml_files = [ROOT.join("_config.yml")] +
             Dir.glob(ROOT.join("_data/**/*.{yml,yaml}")).map { |p| Pathname.new(p) }

errors = []

yaml_files.sort.each do |file|
  relative = file.relative_path_from(ROOT).to_s
  text = file.read(encoding: "UTF-8")

  if text.include?("\t")
    errors << "#{relative}: contains one or more TAB characters. Use spaces only."
    next
  end

  begin
    # Syntax parsing only. This catches indentation, missing colons, malformed
    # lists, and other YAML errors without constructing application objects.
    Psych.parse(text, filename: relative)
    puts "YAML OK: #{relative}"
  rescue Psych::SyntaxError => e
    errors << "#{relative}: line #{e.line}, column #{e.column}: #{e.problem}"
  rescue StandardError => e
    errors << "#{relative}: #{e.class}: #{e.message}"
  end
end

# Detect common accidental duplicate names created by Windows or browser uploads,
# such as "awards_skills (1).yml".
data_files = Dir.glob(ROOT.join("_data/*.{yml,yaml}")).map { |p| Pathname.new(p) }

bad_names = data_files.select do |file|
  file.basename.to_s.match?(/\(\d+\)|\bcopy\b/i)
end

bad_names.each do |file|
  errors << "#{file.relative_path_from(ROOT)}: looks like an accidental duplicate file. Rename or delete it."
end

normalized_groups = data_files.group_by do |file|
  file.basename.to_s
      .downcase
      .sub(/\s*\(\d+\)(?=\.(ya?ml)\z)/, "")
      .sub(/\s+copy(?=\.(ya?ml)\z)/, "")
end

normalized_groups.each_value do |files|
  next unless files.length > 1

  names = files.map { |f| f.relative_path_from(ROOT).to_s }.join(", ")
  errors << "Possible duplicate data files: #{names}"
end

if errors.empty?
  puts
  puts "All YAML data files passed validation."
  exit 0
end

warn
warn "SITE DATA VALIDATION FAILED"
warn "==========================="
errors.each { |error| warn "- #{error}" }
warn
warn "The website was not built or deployed. Fix the errors above and push again."
exit 1
