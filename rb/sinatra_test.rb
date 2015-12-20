
require 'sinatra'
require_relative 'repo'

set :public_folder, File.dirname(__FILE__) + '/..'
set :views, settings.root + '/..'

get '/' do
  data = {:message => "foo"}
  erb :index, :locals => data
end
