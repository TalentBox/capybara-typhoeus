require 'spec_helper'

module TestSessions
  Typhoeus = Capybara::Session.new :typhoeus, TestApp
end

describe Capybara::Session do
  context 'with typhoeus driver' do
    before(:all) do
      @session = TestSessions::Typhoeus
    end

    describe '#driver' do
      it "should be a typhoeus driver" do
        @session.driver.should be_an_instance_of Capybara::Driver::Typhoeus
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :typhoeus
      end
    end

    def extract_results(session)
      YAML.load Nokogiri::HTML(session.body).xpath("//pre[@id='results']").first.text
    end

    after do
      @session.reset!
    end

    describe '#app' do
      it "should remember the application" do
        @session.app.should == TestApp
      end
    end

    describe '#visit' do
      it "should fetch a response from the driver" do
        @session.visit('/')
        @session.body.should include('Hello world!')
        @session.visit('/foo')
        @session.body.should include('Another World')
      end
    end

    describe '#body' do
      it "should return the unmodified page body" do
        @session.visit('/')
        @session.body.should include('Hello world!')
      end
    end

    describe '#source' do
      it "should return the unmodified page source" do
        @session.visit('/')
        @session.source.should include('Hello world!')
      end
    end

    it_should_behave_like "all"
    it_should_behave_like "first"
    it_should_behave_like "find_button"
    it_should_behave_like "find_field"
    it_should_behave_like "find_link"
    it_should_behave_like "find_by_id"
    it_should_behave_like "has_content"
    it_should_behave_like "has_css"
    it_should_behave_like "has_css"
    it_should_behave_like "has_selector"
    it_should_behave_like "has_xpath"
    it_should_behave_like "has_link"
    it_should_behave_like "has_button"
    it_should_behave_like "has_field"
    it_should_behave_like "has_select"
    it_should_behave_like "has_table"
    it_should_behave_like "current_url"
    it_should_behave_like "session without javascript support"
    it_should_behave_like "session with headers support"
    it_should_behave_like "session with status code support"
  end
end
