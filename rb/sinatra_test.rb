
require 'sinatra'

require 'json'
require_relative 'repo'

set :public_folder, File.dirname(__FILE__) + '/..'
set :views, settings.root + '/..'

get '/' do
  data = JSON.generate(Repo.load_user_cards('mpw'))
  erb :index, :locals => {:data => data}
end
