#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

root = Pathname.new(__dir__).parent

projects = root.join("_pages/projects.html")
activities = root.join("_pages/year-archive.html")
toolbar_css = root.join("assets/css/search-toolbar-publication-style.css")

errors = []

[projects, activities, toolbar_css].each do |path|
  errors << "Missing #{path.relative_path_from(root)}" unless path.file?
end

def order_check(text, first, second)
  first_pos = text.index(first)
  second_pos = text.index(second)
  first_pos && second_pos && first_pos < second_pos
end

if projects.file?
  text = projects.read(encoding: "UTF-8")

  unless text.include?("search-toolbar-publication-style.css")
    errors << "Projects page does not load the shared toolbar stylesheet."
  end

  unless order_check(text, 'class="sms-projects__filters"', 'class="sms-projects__search"')
    errors << "Projects filters must appear before the search field."
  end

  unless text.include?("data-project-search") && text.include?("data-project-filter")
    errors << "Projects filtering hooks were changed or removed."
  end
end

if activities.file?
  text = activities.read(encoding: "UTF-8")

  unless text.include?("search-toolbar-publication-style.css")
    errors << "Activities page does not load the shared toolbar stylesheet."
  end

  unless order_check(text, 'class="sms-act-filters"', 'class="sms-act-search"')
    errors << "Activities filters must appear before the search field."
  end

  unless text.include?("data-activity-search") && text.include?("data-activity-filter")
    errors << "Activities filtering hooks were changed or removed."
  end
end

if toolbar_css.file?
  text = toolbar_css.read(encoding: "UTF-8")

  required = [
    "padding: 0.9rem;",
    "border-radius: 10px;",
    "gap: 0.45rem;",
    "flex: 0 1 16rem;",
    "min-height: 2.4rem;",
    "@media (max-width: 800px)"
  ]

  required.each do |rule|
    errors << "Shared toolbar CSS is missing #{rule.inspect}" unless text.include?(rule)
  end
end

if errors.empty?
  puts "Projects and Activities publication-style toolbar check passed."
  exit 0
end

warn "SEARCH TOOLBAR CHECK FAILED"
warn "==========================="
errors.each { |error| warn "- #{error}" }
exit 1
