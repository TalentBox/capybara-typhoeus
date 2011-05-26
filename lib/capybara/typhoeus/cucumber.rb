require 'capybara/typhoeus'

Before('@typhoeus') do
  Capybara.current_driver = :typhoeus
  page.driver.reset_with!
end