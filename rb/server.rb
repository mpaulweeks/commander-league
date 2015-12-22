
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
  redirect to('/mpw'), 303
end

get '/:user_slug' do |user_slug|
  data = get_cards_json(_oracle, user_slug)
  erb :index, :locals => {:data => data}
end

get '/binder/:user_slug' do |user_slug|
  data = get_cards_json(_oracle, user_slug)
  return data
end

put '/binder/sideboard' do
  user_slug = params['user_slug']
  card_name = params['card_name']
  quantity = params['quantity']
  if not (user_slug && card_name && quantity)
    return
  end
  Repo.modify_sideboard(user_slug, card_name, quantity)
  data = get_cards_json(_oracle, user_slug)
  return data
end
