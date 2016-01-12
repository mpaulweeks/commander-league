
require 'sinatra'

require 'json'
require_relative 'repo'
require_relative 'oracle'
require_relative 'differ'

set :public_folder, File.dirname(__FILE__) + '/../public'
set :views, settings.root + '/../view'

_oracle = Oracle.new
_user_slugs = Repo.load_user_slugs

def get_cards_json(oracle, user_slug)
  data = Repo.load_user_cards(user_slug)
  oracle.add_card_meta!(data[:cards])
  return JSON.generate(data)
end

def get_diff_json(oracle, user_slug, params)
  from = params['from']
  to = params['to']
  data = Differ.get_diff(user_slug, from, to)
  oracle.add_card_meta!(data[:cards])
  return JSON.generate(data)
end

def validate_user_slug(user_slugs, user_slug)
  unless user_slugs.include? user_slug
    halt 404
  end
end

# redirect trailing slashes
get %r{(.+)/$} do |r| redirect r; end;

get '/' do
  random_slug = _user_slugs.sample
  redirect to("/#{random_slug}"), 303
end

get '/:user_slug' do |user_slug|
  validate_user_slug(_user_slugs, user_slug)
  data = get_cards_json(_oracle, user_slug)
  erb :index, :locals => {:data => data}
end

get '/api/user/:user_slug' do |user_slug|
  validate_user_slug(_user_slugs, user_slug)
  data = get_cards_json(_oracle, user_slug)
  return data
end

post '/api/user/:user_slug/status' do |user_slug|
  validate_user_slug(_user_slugs, user_slug)
  request.body.rewind  # in case someone already read it
  status_hash = JSON.parse request.body.read
  new_data = Repo.create_statuses!(user_slug, status_hash)
  _oracle.add_card_meta!(new_data[:cards])
  return JSON.generate(new_data)
end

get '/:user_slug/diff' do |user_slug|
  validate_user_slug(_user_slugs, user_slug)
  data = get_diff_json(_oracle, user_slug, params)
  erb :diff, :locals => {:data => data}
end

get '/api/user/:user_slug/diff' do |user_slug|
  validate_user_slug(_user_slugs, user_slug)
  data = get_diff_json(_oracle, user_slug, params)
  return data
end

# shutdown

PID_FILE = 'server.pid'
$shutting_down = false
File.open(PID_FILE, 'w') {|f| f.write Process.pid }
def shut_down
  $shutting_down = true
  puts "Cleaning up %s" % PID_FILE
  File.open(PID_FILE, 'w') {|f| f.write '' }
  puts "Ruby cleanup done!"
end

# Trap ^C
Signal.trap("INT") {
  shut_down
}

# Trap `Kill `
Signal.trap("TERM") {
  shut_down
}

# check for shutdown
def check_for_shut_down
  while File.read(PID_FILE).length > 0
    sleep(5)
  end
  unless $shutting_down
    Process.kill 'INT', Process.pid
  end
end
t = Thread.new{check_for_shut_down()}
