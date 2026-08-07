#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

root = Pathname.new(__dir__).parent

files = {
  profile: root.join("_includes/author-profile.html"),
  scss: root.join("_sass/custom/_mobile-sidebar-profile-fix.scss"),
  main: root.join("assets/css/main.scss"),
  javascript: root.join("assets/js/sidebar-profile-toggle.js")
}

errors = []

files.each do |name, path|
  errors << "Missing #{path.relative_path_from(root)}" unless path.file?
end

if files[:profile].file?
  text = files[:profile].read(encoding: "UTF-8")

  errors << "Toggle button is missing aria-expanded." unless text.include?('aria-expanded="false"')
  errors << "Toggle button is missing aria-controls." unless text.include?('aria-controls="sms-author-contact-links"')
  errors << "Contact list is missing the controlled ID." unless text.include?('id="sms-author-contact-links"')
  errors << "Sidebar toggle script is not loaded." unless text.include?("sidebar-profile-toggle.js")
end

if files[:scss].file?
  text = files[:scss].read(encoding: "UTF-8")

  errors << "Desktop photo is not set to 170px." unless text.include?("--sms-sidebar-photo-size: 170px")
  errors << "Mobile sidebar is not returned to relative positioning." unless text.include?("position: relative !important")
  errors << "Mobile links are not static." unless text.include?("position: static !important")
  errors << "Mobile closed state is missing." unless text.include?("display: none !important")
  errors << "Mobile open state is missing." unless text.include?(".is-open .sms-author-links")
end

if files[:main].file?
  text = files[:main].read(encoding: "UTF-8")
  import_position = text.index('"custom/mobile-sidebar-profile-fix"')
  footer_position = text.index('"custom/sidebar-footer-fix"')

  errors << "main.scss does not import the mobile fix." unless import_position

  if import_position && footer_position && import_position < footer_position
    errors << "The mobile sidebar fix must be imported after sidebar-footer-fix."
  end
end

if files[:javascript].file?
  text = files[:javascript].read(encoding: "UTF-8")

  errors << "JavaScript does not update aria-expanded." unless text.include?('setAttribute("aria-expanded"')
  errors << "JavaScript does not close on Escape." unless text.include?('event.key !== "Escape"')
  errors << "Capture-phase conflict protection is missing." unless text.match?(/,\s*true\s*\)\s*;/m)
end

if errors.empty?
  puts "Sidebar picture and mobile-profile check passed."
  exit 0
end

warn "SIDEBAR MOBILE CHECK FAILED"
warn "==========================="
errors.each { |error| warn "- #{error}" }
exit 1
