require 'bundler/setup'
require 'capybara'
require 'capybara/typhoeus'
require 'capybara/spec/extended_test_app'
require 'capybara/spec/driver'
require 'capybara/spec/session'

alias :running :lambda

Capybara.default_wait_time = 0 # less timeout so tests run faster

RSpec.configure do |config|
  config.after do
    Capybara.default_selector = :xpath
  end
end