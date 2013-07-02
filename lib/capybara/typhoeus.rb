require "capybara"
require "typhoeus"

module Capybara
  module Typhoeus
    autoload :Driver, "capybara/typhoeus/driver"
    autoload :Browser, "capybara/typhoeus/browser"
    autoload :Session, "capybara/typhoeus/session"
  end

  def current_session
    key = "#{current_driver}:#{session_name}:#{app.object_id}"
    session_pool[key] ||= if current_driver==:typhoeus
      ::Capybara::Typhoeus::Session.new current_driver, app
    else
      ::Capybara::Session.new current_driver, app
    end
  end
end

Capybara.register_driver :typhoeus do |app|
  Capybara::Typhoeus::Driver.new app
end
