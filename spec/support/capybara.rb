Capybara.enable_aria_label = true

Capybara.register_driver :selenium_chromium_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.binary = "/usr/bin/chromium"
  options.add_argument("--headless=new")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1400,1400")

  service = Selenium::WebDriver::Chrome::Service.new(
    path: "/usr/bin/chromedriver"
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options:,
    service:
  )
end

RSpec.configure do |config|
  config.before(type: :system) do
    driven_by :selenium_chromium_headless
  end
end
