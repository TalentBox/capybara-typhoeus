require "spec_helper"

Capybara.register_driver :typhoeus_with_custom_timeout do |app|
  Capybara::Typhoeus::Driver.new app, timeout: 1
end

describe Capybara::Typhoeus::Session do

  # Capybara::SpecHelper.run_specs described_class.new(:typhoeus, TestApp), "Typhoeus", skip: [
  #   :js,
  #   :screenshot,
  #   :frames,
  #   :windows,
  #   :server,
  #   :hover
  # ]

  context "with typhoeus driver" do
    it "should use Capybara::Typhoeus::Session" do
      Capybara.current_driver = :typhoeus
      Capybara.current_session.should be_instance_of described_class
    end

    # context "basic authentication" do
    #   subject do
    #     app = Sinatra.new do
    #       use Rack::Auth::Basic do |username, password|
    #         username=="admin" && password=="secret"
    #       end
    #       get("/"){ "Success!" }
    #     end
    #     described_class.new :typhoeus, app
    #   end

    #   it "allow access with right credentials" do
    #     subject.authenticate_with "admin", "secret"
    #     subject.get "/"
    #     subject.status_code.should be 200
    #     subject.source.should == "Success!"
    #   end

    #   it "deny access with wrong credentials" do
    #     subject.authenticate_with "admin", "admin"
    #     subject.get "/"
    #     subject.status_code.should be 401
    #   end
    # end

    # context "timeout" do
    #   subject{ described_class.new :typhoeus, TestApp }

    #   context "default" do
    #     it "is 3 seconds" do
    #       subject.driver.options[:timeout].should == 3
    #     end

    #     it "is used during request" do
    #       subject.get "/slow_response"
    #       subject.should_not be_timed_out
    #     end
    #   end

    #   context "accepts custom timeout" do
    #     subject{ described_class.new :typhoeus_with_custom_timeout, TestApp }

    #     it "is stored in options" do
    #       subject.driver.options[:timeout].should == 1
    #     end

    #     it "is used during request" do
    #       subject.get "/slow_response"
    #       subject.should be_timed_out
    #     end
    #   end
    # end

    context "#host_url returns url with scheme, host, port and path" do
      subject{ described_class.new :typhoeus, TestApp }

      it "with empty url" do
        subject.host_url("").should =~ /\A#{Regexp.escape("http://127.0.0.1")}:\d+\z/
      end

      it "with relative url" do
        subject.host_url("/demo/test").should =~ /\A#{Regexp.escape("http://127.0.0.1")}:\d+\/demo\/test\z/
      end

      it "with absolute url" do
        subject.host_url("http://www.example.com:443/demo/test").should == "http://www.example.com:443/demo/test"
      end
    end

    context "can upload file by setting the body per request" do
      subject do
        app = Sinatra.new do
          post("/"){ request.body }
        end
        described_class.new :typhoeus, app
      end

      it "body is nil be default" do
        subject.request_body.should be_nil
        subject.post "/"
        subject.status_code.should be 200
        subject.source.should == ""
      end

      it "I can send data by setting the body" do
        body = "**raw file content**"
        subject.request_body = body
        subject.request_body.should == body
        subject.post "/"
        subject.status_code.should be 200
        subject.source.should == body
        subject.request_body.should be_nil
      end
    end
  end
end
