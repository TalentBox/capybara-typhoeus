require 'capybara/typhoeus'

Before('@typhoeus') do
  Capybara.current_driver = :typhoeus
end