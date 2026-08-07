#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

root = Pathname.new(__dir__).parent
scss = root.join("_sass/custom/_mobile-sidebar-profile-fix.scss")
main = root.join("assets/css/main.scss")

errors = []

errors << "Missing #{scss.relative_path_from(root)}" unless scss.file?
errors << "Missing #{main.relative_path_from(root)}" unless main.file?

if scss.file?
  text = scss.read(encoding: "UTF-8")

  errors << "Normal desktop photo must be 225px." unless text.include?("--sms-sidebar-photo-size: 225px;")
  errors << "Short desktop photo must be 185px." unless text.include?("--sms-sidebar-photo-size-short-screen: 185px;")
  errors << "Phone photo must remain 96px." unless text.include?("--sms-sidebar-mobile-photo-size: 96px;")
  errors << "Wide desktop 235px rule is missing." unless text.include?("--sms-sidebar-photo-size: 235px;")
  errors << "Desktop avatar wrapper must allow overflow." unless text.include?("overflow: visible !important;")
end

if main.file?
  text = main.read(encoding: "UTF-8")
  mobile = text.index('"custom/mobile-sidebar-profile-fix"')
  old = text.index('"custom/sidebar-footer-fix"')

  errors << "main.scss is missing mobile-sidebar-profile-fix." unless mobile
  if mobile && old && mobile < old
    errors << "mobile-sidebar-profile-fix must remain after sidebar-footer-fix."
  end
end

if errors.empty?
  puts "Large desktop sidebar-photo check passed."
  exit 0
end

warn "LARGE DESKTOP SIDEBAR-PHOTO CHECK FAILED"
warn "========================================"
errors.each { |error| warn "- #{error}" }
exit 1
