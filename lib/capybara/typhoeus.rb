require "capybara"
require "typhoeus"

module Capybara
  module Typhoeus
    autoload :Driver, "capybara/typhoeus/driver"
    autoload :Browser, "capybara/typhoeus/browser"
    autoload :Session, "capybara/typhoeus/session"
  end

  def self.session_pool
    @session_pool ||= Hash.new do |hash, name|
      hash[name] = if current_driver==:typhoeus
        ::Capybara::Typhoeus::Session.new(current_driver, app)
      else
        ::Capybara::Session.new(current_driver, app)
      end
    end
  end
end

Capybara.register_driver :typhoeus do |app|
  Capybara::Typhoeus::Driver.new app
end
