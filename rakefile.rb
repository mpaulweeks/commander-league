require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = 'rb/test/*.rb'
  t.verbose = true
end