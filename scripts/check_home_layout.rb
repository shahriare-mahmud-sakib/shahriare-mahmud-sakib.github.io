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
    layout = data.dig("highlights", "layout") || {}

    errors << "highlights.layout.columns_desktop must be 3." unless layout["columns_desktop"] == 3
    errors << "highlights.layout.columns_tablet must be at least 1." unless layout["columns_tablet"].to_i >= 1
    errors << "highlights.layout.columns_mobile must be at least 1." unless layout["columns_mobile"].to_i >= 1

    cards = data.dig("highlights", "cards")
    errors << "highlights.cards must contain at least three cards." unless cards.is_a?(Array) && cards.length >= 3
  rescue Psych::SyntaxError => e
    errors << "_data/home_profile.yml: line #{e.line}, column #{e.column}: #{e.problem}"
  end
end

if page_file.file?
  text = page_file.read(encoding: "UTF-8")
  errors << "_pages/about.md must use layout: archive." unless text.match?(/^layout:\s*archive\s*$/)
  errors << "_pages/about.md must keep permalink: /." unless text.match?(/^permalink:\s*\/\s*$/)
end

if include_file.file?
  text = include_file.read(encoding: "UTF-8")
  errors << "The include is missing the sms-home-page wrapper." unless text.include?('class="sms-home-page"')
  errors << "The include does not expose columns_desktop." unless text.include?("card_layout.columns_desktop")
  errors << "The include does not close the wrapper." unless text.rstrip.end_with?("</div>")
end

if css_file.file?
  text = css_file.read(encoding: "UTF-8")
  unless text.include?("repeat(var(--sms-profile-columns-desktop, 3)")
    errors << "Desktop card grid is not controlled by the three-column variable."
  end

  if text.include?(".page__content .sms-profile")
    errors << "Old page__content-scoped profile rules remain and may fail in archive layout."
  end
end

if errors.empty?
  puts "Homepage width and profile-grid check passed."
  exit 0
end

warn "HOMEPAGE LAYOUT CHECK FAILED"
warn "============================"
errors.each { |error| warn "- #{error}" }
exit 1
