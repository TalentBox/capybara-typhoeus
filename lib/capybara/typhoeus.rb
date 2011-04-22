module Capybara
  module Driver
    autoload :Typhoeus, 'capybara/driver/typhoeus_driver'
  end
end

Capybara.register_driver :typhoeus do |app|
  Capybara::Driver::Typhoeus.new(app)
end