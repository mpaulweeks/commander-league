
require 'sinatra'
require_relative 'repo'

foo = 0

get '/' do
  foo += 1
  return 'Hello world! foo = ' + foo.to_s
end
