require "bundler/setup"
require "capybara/typhoeus"
require "capybara/spec/spec_helper"

module Capybara
  module SpecHelper
    class << self
      alias_method :run_specs_without_skip, :run_specs
      def run_specs(session, name, options={})
        skip = [
          "#attach_file",
          "#check",
          "#click_button",
          "#click_link",
          "#select",
          "#uncheck",
          "#unselect",
        ]
        @specs.reject!{|spec| skip.include? spec.first}
        run_specs_without_skip session, name, options
      end
    end
  end
end

RSpec.configure do |config|
  Capybara::SpecHelper.configure config
end
