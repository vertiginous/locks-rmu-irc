require 'sinatra/base'
require 'sinatra/session'
require 'rest_client'
require 'json'

class RMUirc < Sinatra::Base

  configure do
    register Sinatra::Session
    set :session_fail, '/login'
    set :session_secret, 'maxim'
  end
  
  get '/' do
    session! # redirects to :session_fail if not logged in
    feed = JSON.parse RestClient.get 'http://rmuapi.heroku.com/irc/log'

    html = '<a href="/logout">logout</a> <a href="/archive.html">old log</a></p>'
    
    feed.each do |row|
      time = Time.parse row[:timestamp]

      log += "<span style='color: grey;'>#{time.mon}\/#{time.day} " + row[:timestamp].gsub(/\d\d:\d\d/).first + "</span>"

      if row[:symbol].eql? 'privmsg'
        log += "&nbsp;<span style='color: blue'>#{row[:nick]}</span>&nbsp;#{row[:text]}"
      else
        log += " ** <span style='color: blue'>#{row[:nick]}</span> <span style='color: red'>#{row[:symbol]}ed</span> #{row[:text]}"
      end
      
      log += "<br />"
    end
    
    log
  end

###
# session management
#
  get '/login' do
    '<form name="input" action="login" method="POST">
      <input type="text" name="secret" value="our little secret" />
      
      <input type="submit" value="submit" />
    </form>'
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
  
  get '/logout' do
    session_end!

    redirect '/'
  end
#
###

end
