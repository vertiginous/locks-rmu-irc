require 'sinatra/base'
require 'sinatra/session'

require 'httparty'

class RMUirc < Sinatra::Base

  register Sinatra::Session

#  set :public, File.expand_path( File.dirname(__FILE__) + '/public')
  set :session_fail, '/login'
  set :session_secret, 'babot is my'

  enable :inline_templates

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end

  class Log
    include HTTParty

    base_uri 'http://rmuapi.heroku.com/'
    format :json
  end

## LOGIN LOGIc
#
  get '/login' do
    erb :lili
  end
  post '/login' do
    if params[:secret].eql? 'rmu1337'
      session_start!
      session[:secret] = params[:secret]
      
      redirect '/'
    else
      redirect '/login'
    end
  end
##
  get '/logout' do
    session_end!

    redirect '/'
  end
#
## LOGIN LOGIc

  get '/' do
    redirect '/latest'
  end

  get '/old' do
    session!

    menu + File.open('archive.html') {|f| f.read }
  end
  
  get '/:filter' do
    session!
    
    @feed = Log.get '/irc/log'
    @feed = @feed.last 200 if params[:filter] == 'latest'
    
    erb :logs
  end
end

__END__

@@ login
%content{ :style => 'text-align: center'}
  %form{ :name => 'input', :action => 'login', :method => 'POST'}
    %input{ :type => 'text', :name => 'secret', :value => 'our little secret'}

    %input{ :type => 'submit', :value => 'submit'}

@@ lili
<div id='content' style='text-align: center'>
  <form name='input' action='login' method='POST'>
    <input type='text' name='secret' value='our little secret' />
    
    <input type='submit' value='submit' />
  </form
</div>