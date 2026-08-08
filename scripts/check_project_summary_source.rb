#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "pathname"

root = Pathname.new(__dir__).parent

data_file = root.join("_data/projects/model-solid-waste-management-system.yml")
portfolio_file = root.join("_portfolio/model-solid-waste-management-system.md")
include_file = root.join("_includes/project-timeline-item.html")

errors = []

[data_file, portfolio_file, include_file].each do |path|
  errors << "Missing #{path.relative_path_from(root)}" unless path.file?
end

if data_file.file?
  begin
    data = YAML.safe_load(data_file.read(encoding: "UTF-8"), aliases: true) || {}

    if data["summary"].to_s.strip.empty?
      errors << "Capstone YAML summary is empty."
    end

    unless data["title"] == "A Model Solid Waste Management System at Community Level"
      errors << "Unexpected capstone title in YAML."
    end
  rescue Psych::SyntaxError => e
    errors << "_data/projects/model-solid-waste-management-system.yml: line #{e.line}, column #{e.column}: #{e.problem}"
  end
end

if portfolio_file.file?
  text = portfolio_file.read(encoding: "UTF-8")

  unless text.include?('project_data_key: "model-solid-waste-management-system"')
    errors << "Portfolio page does not point to the capstone YAML data."
  end

  unless text.include?("show_on_projects: true")
    errors << "Portfolio page is not enabled on the Projects index."
  end
end

if include_file.file?
  text = include_file.read(encoding: "UTF-8")

  unless text.include?("site.data.projects[project_page.project_data_key]")
    errors << "Timeline include does not load nested project YAML data."
  end

  unless text.include?("project.summary")
    errors << "Timeline include does not render the YAML summary."
  end

  unless text.include?("project_page.summary")
    errors << "Fallback support for older portfolio projects is missing."
  end
end

if errors.empty?
  puts "Capstone Projects-page summary source check passed."
  exit 0
end

warn "PROJECT SUMMARY SOURCE CHECK FAILED"
warn "==================================="
errors.each { |error| warn "- #{error}" }
exit 1
