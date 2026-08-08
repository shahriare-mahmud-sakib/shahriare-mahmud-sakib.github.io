#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "pathname"
require "set"

root = Pathname.new(__dir__).parent

data_file = root.join("_data/projects/model-solid-waste-management-system.yml")
page_file = root.join("_portfolio/model-solid-waste-management-system.md")
layout_file = root.join("_layouts/project.html")
include_file = root.join("_includes/project-timeline-item.html")
style_file = root.join("assets/css/project-detail-enhanced.scss")

errors = []

[data_file, page_file, layout_file, include_file, style_file].each do |path|
  errors << "Missing #{path.relative_path_from(root)}" unless path.file?
end

project = {}

if data_file.file?
  begin
    project = YAML.safe_load(data_file.read(encoding: "UTF-8"), aliases: true) || {}
  rescue Psych::SyntaxError => e
    errors << "#{data_file.relative_path_from(root)}: line #{e.line}, column #{e.column}: #{e.problem}"
  end
end

if project.any?
  required = %w[title cover_image summary sections]
  required.each do |key|
    errors << "Project YAML is missing #{key}." if project[key].nil?
  end

  unless project["cover_image"] == "/images/projects/model-solid-waste-management-system/cover.png"
    errors << "cover_image must use the repository cover.png file."
  end

  internal_paths = []

  internal_paths << project["cover_image"] if project["cover_image"]

  Array(project["gallery"]).each do |item|
    internal_paths << item["image"]
  end

  Array(project["links"]).each do |link|
    internal_paths << link["url"] unless link["external"]
  end

  internal_paths.compact.each do |url|
    next unless url.start_with?("/")

    file = root.join(url.sub(%r{\A/}, ""))
    errors << "Referenced file is missing: #{url}" unless file.file?
  end

  ids = Array(project["sections"]).map { |section| section["id"].to_s }
  duplicates = ids.group_by(&:itself).select { |_id, values| values.length > 1 }.keys
  duplicates.each { |id| errors << "Duplicate section id: #{id}" }
end

if page_file.file?
  text = page_file.read(encoding: "UTF-8")
  errors << "Portfolio page must define project_data_key." unless text.include?('project_data_key: "model-solid-waste-management-system"')
  errors << "Portfolio page must use layout: project." unless text.match?(/^layout:\s*project\s*$/)
end

if layout_file.file?
  text = layout_file.read(encoding: "UTF-8")
  errors << "Project layout must inherit archive width." unless text.match?(/^layout:\s*archive\s*$/)
  errors << "Project layout does not load data-project YAML." unless text.include?("site.data.projects")
end

if include_file.file?
  text = include_file.read(encoding: "UTF-8")
  errors << "Timeline item does not load data-project YAML." unless text.include?("site.data.projects")
end

if errors.empty?
  puts "Capstone project page check passed."
  exit 0
end

warn "CAPSTONE PROJECT PAGE CHECK FAILED"
warn "=================================="
errors.each { |error| warn "- #{error}" }
exit 1
