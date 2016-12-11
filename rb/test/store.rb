
require "minitest/autorun"
require_relative '../file_path'
require_relative '../store'

require 'json'

class StoreTest < Minitest::Test

  def test_now
    assert_equal Time.now.inspect, Store.now_str
    assert_equal Time.now.inspect, Store.now_time.inspect
  end

  def test_load_database
    FilePath.stub :users, FilePath.test_users do
    FilePath.stub :prices, FilePath.test_prices do
      db_cache = Store.load_database

      assert_includes db_cache[Store::USER], 'mpw'
      assert_includes db_cache[Store::WALLET], 'mpw'
      assert_includes db_cache[Store::CARD], 'Abandon Hope'
      assert_includes db_cache[Store::STATUS], 'mpw'

      assert_equal 2, db_cache[Store::WALLET]['mpw'].length
      assert_equal 1, db_cache[Store::WALLET]['qwerty'].length
    end
    end
  end
end
