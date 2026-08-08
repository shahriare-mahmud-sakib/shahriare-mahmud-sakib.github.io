#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "pathname"

root = Pathname.new(__dir__).parent
page = root.join("_portfolio/model-solid-waste-management-system.md")
cover = root.join("images/projects/model-solid-waste-management-system/cover.png")
data = root.join("_data/projects/model-solid-waste-management-system.yml")

errors = []

errors << "Missing #{page.relative_path_from(root)}" unless page.file?

if page.file?
  text = page.read(encoding: "UTF-8")
  match = text.match(/\A---\s*\n(.*?)\n---/m)

  if match.nil?
    errors << "Capstone portfolio file has no YAML front matter."
  else
    begin
      fm = YAML.safe_load(match[1], aliases: true) || {}

      required = [
        "project_data_key",
        "show_on_projects",
        "order",
        "filter",
        "timeline_year",
        "timeline_icon",
        "project_type",
        "status",
        "period",
        "discipline",
        "role",
        "cover_image",
        "summary",
        "highlights",
        "tools"
      ]

      required.each do |key|
        value = fm[key]
        if value.nil? || (value.respond_to?(:empty?) && value.empty?)
          errors << "Capstone timeline front matter is missing #{key}."
        end
      end

      unless fm["project_data_key"] == "model-solid-waste-management-system"
        errors << "project_data_key changed; detail page may no longer use its existing YAML."
      end

      unless fm["show_on_projects"] == true
        errors << "show_on_projects must remain true."
      end

      unless fm["cover_image"] == "/images/projects/model-solid-waste-management-system/cover.png"
        errors << "Timeline card must use cover.png."
      end

      unless Array(fm["highlights"]).length >= 3
        errors << "At least three timeline highlights are required."
      end

      unless Array(fm["tools"]).length >= 3
        errors << "Timeline tool tags are missing."
      end
    rescue Psych::SyntaxError => e
      errors << "Invalid front matter: line #{e.line}, column #{e.column}: #{e.problem}"
    end
  end
end

# These files already exist in the repository and are intentionally not changed
# by this package.
unless cover.file?
  warn "Note: cover.png is not in this small repair package. It must remain in the repository."
end

unless data.file?
  warn "Note: detailed project YAML is not in this small repair package. Keep the existing repository file."
end

if errors.empty?
  puts "Capstone timeline-card check passed."
  exit 0
end

warn "CAPSTONE TIMELINE-CARD CHECK FAILED"
warn "=================================="
errors.each { |error| warn "- #{error}" }
exit 1
