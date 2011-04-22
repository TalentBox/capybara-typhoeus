require 'spec_helper'

describe Capybara::Driver::Typhoeus do
  before do
    @driver = Capybara::Driver::Typhoeus.new TestApp
  end
  
  context "in remote mode" do
    it_should_behave_like "driver"
    it_should_behave_like "driver with header support"
    it_should_behave_like "driver with status code support"
    # neither supports cookies nor follows redirect automatically
  end
  
end