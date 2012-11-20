require 'spec_helper'

describe Capybara::Driver::Typhoeus do
  before do
    @driver = described_class.new TestApp
  end

  context "in remote mode" do
    it_should_behave_like "driver"
    it_should_behave_like "driver with header support"
    it_should_behave_like "driver with status code support"
    # neither supports cookies nor follows redirect automatically
  end

  context "basic authentication" do
    subject do
      app = Sinatra.new do
        use Rack::Auth::Basic do |username, password|
          username=="admin" && password=="secret"
        end
        get("/"){ "Success!" }
      end
      described_class.new app
    end

    it "allow access with right credentials" do
      subject.authenticate_with "admin", "secret"
      subject.get "/"
      subject.status_code.should be 200
      subject.source.should == "Success!"
    end

    it "deny access with wrong credentials" do
      subject.authenticate_with "admin", "admin"
      subject.get "/"
      subject.status_code.should be 401
    end
  end

end
