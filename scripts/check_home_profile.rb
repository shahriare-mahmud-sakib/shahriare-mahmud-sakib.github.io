#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "pathname"

root = Pathname.new(__dir__).parent
data_file = root.join("_data/home_profile.yml")
page_file = root.join("_pages/about.md")
include_file = root.join("_includes/home-profile-section.html")
css_file = root.join("assets/css/home-profile-section.css")

errors = []

[data_file, page_file, include_file, css_file].each do |path|
  errors << "Missing #{path.relative_path_from(root)}" unless path.file?
end

if data_file.file?
  begin
    data = YAML.safe_load(data_file.read(encoding: "UTF-8"), aliases: true) || {}
    introduction = data.dig("page", "introduction")

    unless introduction.is_a?(Array) && introduction.any? { |p| !p.to_s.strip.empty? }
      errors << "_data/home_profile.yml: page.introduction must contain at least one paragraph."
    end

    unless data.dig("highlights", "cards").is_a?(Array)
      errors << "_data/home_profile.yml: highlights.cards must be a YAML list."
    end
  rescue Psych::SyntaxError => e
    errors << "_data/home_profile.yml: line #{e.line}, column #{e.column}: #{e.problem}"
  end
end

if page_file.file?
  page_text = page_file.read(encoding: "UTF-8")
  unless page_text.include?("{% include home-profile-section.html %}")
    errors << "_pages/about.md must include home-profile-section.html."
  end
end

if include_file.file?
  include_text = include_file.read(encoding: "UTF-8")

  intro_position = include_text.index("profile_data.page.introduction")
  highlights_position = include_text.index("profile_data.highlights")

  errors << "_includes/home-profile-section.html does not render page.introduction." unless intro_position
  errors << "_includes/home-profile-section.html does not render highlights." unless highlights_position

  if intro_position && highlights_position && intro_position > highlights_position
    errors << "About introduction must appear before Profile at a Glance."
  end

  unless include_text.include?("| markdownify")
    errors << "The introduction should use markdownify so YAML links render correctly."
  end
end

if errors.empty?
  puts "Home page profile check passed."
  exit 0
end

warn "HOME PAGE PROFILE CHECK FAILED"
warn "=============================="
errors.each { |error| warn "- #{error}" }
exit 1
