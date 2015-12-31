
require "minitest/autorun"
require_relative '../store'

require 'json'

class StoreTest < Minitest::Test

  def test_now
    assert_equal Time.now.inspect, Store.now_str
    assert_equal Time.now.inspect, Store.now_time.inspect
  end

  def test_load_database
    FilePath.stub :database, 'json/test/database.json' do
      puts Store.load_database[Store::WALLET]
    end
  end
end