require "spec_helper"

Capybara.register_driver :typhoeus_with_custom_timeout do |app|
  Capybara::Typhoeus::Driver.new app, timeout: 1
end

module TestSessions
  TyphoeusTest = Capybara::Session.new(:typhoeus, TestApp)
  TyphoeusTestCustomTimeout = Capybara::Session.new(:typhoeus_with_custom_timeout, TestApp)
end

skipped_tests = %i[
  js
  modals
  screenshot
  frames
  windows
  send_keys
  server
  hover
  about_scheme
  download
  css
  scroll
]
Capybara::SpecHelper.run_specs TestSessions::TyphoeusTest, 'Typhoeus', capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when /#attach_file/
    skip "Typhoeus driver doesn't support #attach_file"
  when /#check/
    skip "Typhoeus driver doesn't support #check"
  when /#uncheck/
    skip "Typhoeus driver doesn't support #uncheck"
  when /#click/
    skip "Typhoeus driver doesn't support #click"
  when /#select/
    skip "Typhoeus driver doesn't support #select"
  when /#unselect/
    skip "Typhoeus driver doesn't support #unselect"
  when /has_css\? should support case insensitive :class and :id options/
    skip "Nokogiri doesn't support case insensitive CSS attribute matchers"
  end
end

RSpec.describe Capybara::Typhoeus::Session do

  context "with typhoeus driver" do
    let(:session) { TestSessions::TyphoeusTest }

    describe '#driver' do
      it 'should be a rack test driver' do
        expect(session.driver).to be_an_instance_of(Capybara::Typhoeus::Driver)
      end
    end

    describe '#mode' do
      it 'should remember the mode' do
        expect(session.mode).to eq(:typhoeus)
      end
    end

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
      subject{ described_class.new :typhoeus, TestApp }

      context "default" do
        it "is 3 seconds" do
          subject.timeout.should == 3
        end

        it "is used during request" do
          subject.get "/slow_response"
          subject.should_not be_timed_out
        end
      end

      context "accepts custom timeout" do
        subject{ described_class.new :typhoeus_with_custom_timeout, TestApp }

        it "is stored in options" do
          subject.timeout.should == 1
        end

        it "is used during request" do
          subject.get "/slow_response"
          subject.should be_timed_out
        end
      end
    end

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
