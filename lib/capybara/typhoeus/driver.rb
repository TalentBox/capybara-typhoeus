class Capybara::Typhoeus::Driver < Capybara::RackTest::Driver

  attr_writer :as, :with_headers, :with_params, :with_options
  attr_reader :login, :password, :params_encoding

  def initialize(app, **options)
    raise ArgumentError, "typhoeus requires a rack application, but none was given" unless app
    option_with_default = {timeout: 3, forbid_reuse: true}.merge(options)
    super app, **option_with_default
    @params_encoding = :typhoeus
  end

  def browser
    @browser ||= Capybara::Typhoeus::Browser.new self
  end

  def needs_server?
    true
  end

  PARAMS_ENCODING_ALLOWED_VALUES = [:typhoeus, :rack, :multi, :none]
  def params_encoding=(value)
    if PARAMS_ENCODING_ALLOWED_VALUES.include?(value)
      @params_encoding = value
    else
      raise ArgumentError, "Allowed values are: #{PARAMS_ENCODING_ALLOWED_VALUES.map(&:inspect).join(", ")}"
    end
  end

  [:get, :post, :put, :delete, :head, :patch, :request].each do |method|
    define_method(method) do |url, params={}, headers={}, &block|
      browser.reset_host!
      browser.process method, url, params, headers, &block
    end
  end

  def reset!
    @login = nil
    @password = nil
    super
  end

  def timed_out?
    response.timed_out?
  end

  def reset_with!
    @with_headers = {}
    @with_params = {}
    @with_options = {}
    @as = nil
  end

  def as
    @as ||= "application/json"
  end

  def with_headers
    @with_headers ||= {}
  end

  def with_params
    @with_params ||= {}
  end

  def with_options
    @with_options ||= {}
  end

  def authenticate_with(login, password)
    @login, @password = login, password
  end

  def auth?
    login && password
  end

  def status_code
    response.code
  end

  def body
    browser.html
  end

  def xml
    browser.json
  end

  def json
    browser.json
  end

  def request_body
    browser.request_body
  end

  def request_body=(value)
    browser.request_body = value
  end

end
