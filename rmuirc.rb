require 'sinatra/base'
require 'sinatra/session'
require 'httparty'

class RMUirc < Sinatra::Base

  register Sinatra::Session

  set :public, File.expand_path( File.dirname(__FILE__) + '/public')

  set :session_fail, '/login'
  set :session_secret, 'lol'
  
  helpers do
    def menu
      "<div style='margin: 1em; padding: 1em; width: auto; background: orange; font-family: helvetica, arial;'>
        <p><h1><a href='/latest'>REcENT LOG</a></h1></p>
        <p><h1><a href='/full'>FULL LOG</a></h1></p>
        <p><h1><a href='/old'>OLD LOG</a></h1></p>
      </div>"
    end
  end
  
  class Log
    include HTTParty

    base_uri 'http://rmuapi.heroku.com/'
    format :json
  end

## LOGIN LOGIc
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
##
  get '/logout' do
    session_end!

    redirect '/'
  end
#
## LOGIN LOGIc

  get '/' do
    menu
  end
  
  get '/old' do
    session!

    html :archive
  end
  
  get '/:filter' do
    session!

    feed = Log.get '/irc/log'
    feed = feed.last 200 if params[:filter] == 'latest'

    html = '<style>body {font-family: helvetica; arial; font-size: 1.2em; margin-left: 2em;}</style><p><a href="/">back</a></p>' + menu

    feed.each do |row|
      next if row.nil?
      
      html += "<span style='color: grey;'>#{Time.parse( row['timestamp'].to_s ).strftime('%b %d, %H:%M:%S')}</span>"

      if row["symbol"] == 'privmsg'
        html += "&nbsp;<span style='color: blue'>#{row["nick"]}</span>&nbsp;#{row["text"]}"
      else
        html += "&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style='color: red'>#{row["symbol"].to_s.upcase}ED</span> <span style='color: blue'>#{row["nick"]}</span>"
      end
      
      html += "<br />"
    end
    
    html
    
  end

end
