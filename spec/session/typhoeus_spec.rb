require "spec_helper"

Capybara.register_driver :typhoeus_with_custom_timeout do |app|
  Capybara::Typhoeus::Driver.new app, timeout: 1
end

describe Capybara::Typhoeus::Session do

  Capybara::SpecHelper.run_specs described_class.new(:typhoeus, TestApp), "Typhoeus", skip: [
    :js,
    :screenshot,
    :frames,
    :windows,
    :server,
    :hover
  ]

  context "with typhoeus driver" do
    context "basic authentication" do
      subject do
        app = Sinatra.new do
          use Rack::Auth::Basic do |username, password|
            username=="admin" && password=="secret"
          end
          get("/"){ "Success!" }
        end
        described_class.new :typhoeus, app
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

    context "timeout" do
      context "default" do
        subject{ described_class.new :typhoeus, TestApp }

        it "is 3 seconds" do
          subject.driver.options[:timeout].should == 3
        end

        it "is used during request" do
          subject.get "/slow_response"
          subject.should_not be_timed_out
        end
      end

      context "accepts custom timeout" do
        subject{ described_class.new :typhoeus_with_custom_timeout, TestApp }

        it "is stored in options" do
          subject.driver.options[:timeout].should == 1
        end

        it "is used during request" do
          subject.get "/slow_response"
          subject.should be_timed_out
        end
      end
    end
  end
end
