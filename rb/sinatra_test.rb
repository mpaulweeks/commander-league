
require 'sinatra'

require 'json'
require_relative 'repo'

set :public_folder, File.dirname(__FILE__) + '/..'
set :views, settings.root + '/..'

get '/' do
  data = JSON.generate(Repo.load_user_cards('mpw'))
  erb :index, :locals => {:data => data}
end

get '/binder/:user_slug' do |user_slug|
  data = JSON.generate(Repo.load_user_cards(user_slug))
  return data
end
