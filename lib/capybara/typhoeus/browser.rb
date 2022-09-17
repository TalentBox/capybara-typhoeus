module Typhoeus
  class Response
    def redirect?
      [301, 302, 303, 307].include? code
    end

    alias_method :status, :code

    def [](key)
      headers[key]
    end
  end
end

class Capybara::Typhoeus::Browser < Capybara::RackTest::Browser

  LastRequest = Struct.new(:method, :url, :params, :headers) do
    def path
      URI.parse(url).path
    end
  end

  attr_accessor :request_body
  attr_reader :last_request
  attr_reader :last_response

  def reset_cache!
    @xml = nil
    @json = nil
    super
  end

  def refresh
    reset_cache!
    send(last_request.method, last_request.url, last_request.params, last_request.headers)
  end

  def current_url
    return "" unless last_response

    uri = build_uri(last_response.effective_url)
    uri.fragment = @current_fragment if @current_fragment
    uri.to_s
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
        Capybara::HTML html
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
    @json ||= JSON.parse html
  end

  [:get, :post, :put, :delete, :head, :patch, :request].each do |method|
    define_method(method) do |url, params={}, headers={}, &block|
      @last_request = LastRequest.new(method, url, params, headers)
      uri = URI.parse url
      opts = driver.with_options
      opts[:method] = method
      opts[:headers] = driver.with_headers.merge(
        {"Content-Type" => driver.as, "Accept" => driver.as}.merge headers
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
      opts[:params_encoding] = params.delete(:params_encoding) || driver.params_encoding
      opts[:params] = driver.with_params.merge(params)
      if request_body
        opts[:body] = request_body
        @request_body = nil
      end
      @last_response = Typhoeus::Request.send method, uri.to_s, opts
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
