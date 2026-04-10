# frozen_string_literal: true

# Single-threaded Puma so Action Cable's async adapter delivers broadcasts to WebSocket
# clients on the same thread pool (avoids missed Turbo Stream updates under Threads 0:4).
Capybara.server = :puma, { Silent: true, Threads: "1:1" }

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--window-size=1400,900")
  options.add_argument("--disable-gpu")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  # satisfy ApplicationController#allow_browser(:modern) in test
  options.add_argument(
    "--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " \
    "(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :selenium_chrome_headless

Before("@javascript") do
  Capybara.current_driver = :selenium_chrome_headless
end

After("@javascript") do
  Capybara.reset_sessions!
  Capybara.use_default_driver
end
