
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
      db_cache = Store.load_database

      assert db_cache[Store::USER].include? 'mpw'
      assert db_cache[Store::WALLET].include? 'mpw'
      assert db_cache[Store::CARD].include? 'Abandon Hope'
      assert db_cache[Store::STATUS].include? 'mpw'

      assert_equal 2, db_cache[Store::WALLET]['mpw'].length
      assert_equal 1, db_cache[Store::WALLET]['qwerty'].length
    end
  end
end
