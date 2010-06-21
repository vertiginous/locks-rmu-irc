set :app_file, File.expand_path( File.dirname(__FILE__) + '/../rmuirc.rb' )
set :public, File.expand_path( File.dirname(__FILE__) + '/../public' )
set :env, :development

require 'rmuirc'

use Rack::ShowExceptions

run Sinatra.application
