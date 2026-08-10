#!/usr/bin/env ruby
# frozen_string_literal: true
require "pathname"

root = Pathname.new(__dir__).parent
page = root.join("_pages/skills.html")
css = root.join("assets/css/awards-skills-search-toolbar.css")
errors = []

[page, css].each { |p| errors << "Missing #{p.relative_path_from(root)}" unless p.file? }

if page.file?
  text = page.read(encoding: "UTF-8")
  errors << "Toolbar stylesheet not loaded." unless text.include?("awards-skills-search-toolbar.css")
  f = text.index('class="sms-filters"')
  s = text.index('class="sms-search"')
  errors << "Filters/search missing." unless f && s
  errors << "Filters must appear before search." if f && s && f > s
  errors << "data-skill-search missing." unless text.include?("data-skill-search")
  errors << "data-skill-filter missing." unless text.include?("data-skill-filter")
  errors << "Awards content was removed." unless text.include?("sms-award-timeline")
  errors << "Skill groups were removed." unless text.include?("sms-groups")
  errors << "Existing JS missing." unless text.include?("awards-skills-filter.js")
end

if css.file?
  text = css.read(encoding: "UTF-8")
  %w[
    .sms-skills\ .sms-controls
    border-radius:\ 10px;
    flex:\ 0\ 1\ 16rem;
    min-height:\ 2.4rem;
  ].each do |needle|
    errors << "Missing CSS rule #{needle}" unless text.include?(needle.gsub("\\", ""))
  end
  errors << "800px mobile breakpoint missing." unless text.include?("@media (max-width: 800px)")
end

if errors.empty?
  puts "Awards & Skills search-toolbar check passed."
  exit 0
end

warn "AWARDS & SKILLS TOOLBAR CHECK FAILED"
errors.each { |e| warn "- #{e}" }
exit 1
