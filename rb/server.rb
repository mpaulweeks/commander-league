
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

get '/api/user/:user_slug' do |user_slug|
  data = get_cards_json(_oracle, user_slug)
  return data
end

post '/api/user/:user_slug/status' do |user_slug|
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  cards = Repo.create_statuses!(user_slug, data)
  _oracle.add_card_meta!(cards)
  data = JSON.generate(cards)
  return data
end
