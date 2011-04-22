require 'capybara/spec/test_app'

class ExtendedTestApp < TestApp
  set :environment, :production
  
  get %r{/redirect_to/(.*)} do
    redirect params[:captures]
  end
  
  get '/host' do
    "current host is #{request.host}"
  end
end

if __FILE__ == $0
  Rack::Handler::Mongrel.run ExtendedTestApp, :Port => 8070
end