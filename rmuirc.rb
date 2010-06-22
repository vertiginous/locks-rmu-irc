require 'sinatra/base'
require 'sinatra/session'
require 'rest_client'
require 'json'

class RMUirc < Sinatra::Base

    register Sinatra::Session
    set :session_fail, '/login'
    set :session_secret, 'mamamia'
    set :public, '/public'
  
  get '/da' do
    feed = JSON.parse RestClient.get('http://rmuapi.heroku.com/irc/log')
    html = ''
    
    i = 1
    feed.each do |entry|
      html += i.to_s if entry['timestamp'] == nil
      i = i.next
    end
    
    html
  end
  
  get '/' do
    "
      <p><h1><a href='/latest'>REcENT LOG</a></h1></p>
      <p><h1><a href='/full'>FULL LOG</a></h1></p>
      <p><h1><a href='/archive.html'>OLD LOG</a></h1></p>
    "
  end
  
  get '/latest' do
    feed = JSON.parse RestClient.get('http://rmuapi.heroku.com/irc/log')

    html = '<style>body {font-family: helvetica; arial; font-size: 1.2em; margin-left: 2em;}</style><p><a href="/">back</a></p>'

    feed.last(200).each do |row|
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

  get '/full' do
    session!

    feed = JSON.parse RestClient.get('http://rmuapi.heroku.com/irc/log')

    html = '<h1><a href="/">back</a></h1>'

    feed.each do |row|
      next if row.nil?

      time = Time.parse row['timestamp'].to_s
      
      html += "<span style='color: grey;'>#{time.mon}\/#{time.day} " + row["timestamp"].to_s.gsub(/\d\d:\d\d/).first + "</span>"

      if row["symbol"] == 'privmsg'
        html += "&nbsp;<span style='color: blue'>#{row["nick"]}</span>&nbsp;#{row["text"]}"
      else
        html += " ** <span style='color: blue'>#{row["nick"]}</span> <span style='color: red'>#{row["symbol"]}ed</span> #{row["text"]}"
      end
      
      html += "<br />"
    end

    html

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
