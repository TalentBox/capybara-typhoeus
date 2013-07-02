module Typhoeus
  class Response
    def redirect?
      [301, 302, 303, 307].include? code
    end

    def [](key)
      headers[key]
    end
  end
end

class Capybara::Typhoeus::Browser < Capybara::RackTest::Browser

  attr_reader :last_response, :client

  def initialize(driver)
    @client = Typhoeus::Hydra.new
    super
  end

  def reset_cache!
    @xml = nil
    @json = nil
    super
  end

  def current_url
    last_response ? last_response.effective_url : ""
  end

  def dom
    @dom ||= begin
      content_type = if last_response
        last_response.headers["Content-Type"].to_s[/\A[^;]+/]
      else
        ""
      end
      if content_type.include? "/xml"
        xml
      else
        Nokogiri::HTML html
      end
    end
  end

  def html
    last_response ? last_response.body : ""
  end

  def xml
    @xml ||= Nokogiri::XML html
  end

  def json
    @json ||= Yajl::Parser.parse html
  end

  [:get, :post, :put, :delete, :head, :patch, :request].each do |method|
    define_method(method) do |url, params={}, headers={}, &block|
      uri = URI.parse url
      opts = driver.with_options
      opts[:method] = method
      opts[:headers] = driver.with_headers.merge(
        headers.merge("Content-Type" => driver.as, "Accept" => driver.as)
      )
      referer = opts[:headers].delete "HTTP_REFERER"
      opts[:headers]["Referer"] = referer if referer
      opts[:headers]["Cookie"] ||= cookie_jar.for uri
      driver.options.each do |key, value|
        next if Capybara::RackTest::Driver::DEFAULT_OPTIONS.has_key? key
        opts[key] = value
      end
      if driver.auth?
        opts[:httpauth] = :basic
        opts[:userpwd] = "#{driver.login}:#{driver.password}"
      end
      if params.is_a? Hash
        opts[:params] = driver.with_params.merge(params)
      else
        opts[:params] = driver.with_params
        opts[:body] = params
      end
      request = Typhoeus::Request.new uri.to_s, opts
      client.queue request
      client.run
      @last_response = request.response
      if last_response.timed_out?
        $stderr.puts "#{method.to_s.upcase} #{uri.to_s}: time out" if $DEBUG
      elsif last_response.code==0
        $stderr.puts "#{method.to_s.upcase} #{uri.to_s}: #{last_response.return_message}" if $DEBUG
      else
        cookie_jar.merge last_response.headers["Set-Cookie"], uri
      end
      last_response
    end
  end

private

  def cookie_jar
    @cookie_jar ||= Rack::Test::CookieJar.new [], current_host
  end

end
