
require 'sinatra'

require 'json'
require_relative 'repo'
require_relative 'oracle'

set :public_folder, File.dirname(__FILE__) + '/..'
set :views, settings.root + '/..'

_oracle = Oracle.new

def get_cards_json(oracle, user_slug)
  data = Repo.load_user_cards(user_slug)
  oracle.add_card_meta!(data[:cards])
  return JSON.generate(data)
end

get '/' do
  user_slug = 'mpw'
  data = get_cards_json(_oracle, user_slug)
  erb :index, :locals => {:data => data}
end

get '/binder/:user_slug' do |user_slug|
  data = get_cards_json(_oracle, user_slug)
  return data
end
