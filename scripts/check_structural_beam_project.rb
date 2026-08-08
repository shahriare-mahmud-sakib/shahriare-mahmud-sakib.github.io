#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "pathname"

root = Pathname.new(__dir__).parent
data_file = root.join("_data/projects/structural-beam-analysis.yml")
portfolio_file = root.join("_portfolio/structural-beam-analysis.md")
layout_file = root.join("_layouts/project.html")

errors = []

[data_file, portfolio_file].each do |path|
  errors << "Missing #{path.relative_path_from(root)}" unless path.file?
end

def read_front_matter(path)
  text = path.read(encoding: "UTF-8")
  match = text.match(/\A---\s*\n(.*?)\n---/m)
  return nil unless match

  YAML.safe_load(match[1], aliases: true) || {}
end

data = {}
portfolio = {}

if data_file.file?
  begin
    data = YAML.safe_load(data_file.read(encoding: "UTF-8"), aliases: true) || {}
  rescue Psych::SyntaxError => e
    errors << "#{data_file.relative_path_from(root)}: line #{e.line}, column #{e.column}: #{e.problem}"
  end
end

if portfolio_file.file?
  begin
    portfolio = read_front_matter(portfolio_file) || {}
  rescue Psych::SyntaxError => e
    errors << "#{portfolio_file.relative_path_from(root)}: invalid front matter near line #{e.line}: #{e.problem}"
  end
end

unless portfolio["project_data_key"] == "structural-beam-analysis"
  errors << "Portfolio project_data_key must be structural-beam-analysis."
end

# These fields determine the visual content of the main Projects timeline card.
# They must remain identical so the user-requested card is not changed.
timeline_fields = %w[
  title
  show_on_projects
  order
  filter
  timeline_year
  timeline_icon
  project_type
  status
  period
  discipline
  course
  role
  cover_image
  cover_alt
  summary
  highlights
  tools
  keywords
]

timeline_fields.each do |field|
  unless data[field] == portfolio[field]
    errors << "Timeline field #{field.inspect} differs between YAML and portfolio front matter."
  end
end

if data.any?
  errors << "Detailed YAML has no sections." unless data["sections"].is_a?(Array) && !data["sections"].empty?
  errors << "Detailed YAML has no gallery." unless data["gallery"].is_a?(Array) && !data["gallery"].empty?
  errors << "Expected two beam systems metric." unless data.dig("metrics", 0, "value").to_s == "2"
end

if layout_file.file?
  layout_text = layout_file.read(encoding: "UTF-8")
  unless layout_text.include?("site.data.projects[page.project_data_key]")
    errors << "_layouts/project.html does not support project_data_key."
  end
else
  warn "Note: _layouts/project.html is not part of this small package; keep the existing repository file."
end

if errors.empty?
  puts "Structural Beam Analysis detail-page check passed."
  puts "Main Projects timeline card fields are unchanged."
  exit 0
end

warn "STRUCTURAL BEAM PROJECT CHECK FAILED"
warn "===================================="
errors.each { |error| warn "- #{error}" }
exit 1
