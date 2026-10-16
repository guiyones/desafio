require "test_helper"

Capybara.enable_aria_label = true

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 375, 812 ] do |options|
    options.binary = "/usr/bin/chromium"
  end
end
