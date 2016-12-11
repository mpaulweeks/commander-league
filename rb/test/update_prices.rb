
require "minitest/autorun"
require_relative '../file_path'
require_relative '../script/update_prices'

require 'json'

class UpdatePricesTest < Minitest::Test

  def setup
    @test_users = 'rb/test/tmp/users.json'
    @test_prices = 'rb/test/tmp/prices.json'
    FileUtils.cp(FilePath.test_users, @test_users)
    FileUtils.cp(FilePath.test_prices, @test_prices)
  end

  def assert_changes(card_name, market_price, expected_before, expected_after)
    FilePath.stub :users, @test_users do
    FilePath.stub :prices, @test_prices do
      Market.stub :get_price, market_price do
        before_db = Store.load_database
        assert_equal expected_before, before_db[Store::CARD][card_name]['price']
        update_prices
        after_db = Store.load_database
        assert_equal expected_after, after_db[Store::CARD][card_name]['price']
      end
    end
    end
  end

  def test_updates_sideboard_prices
    card_name = 'Forest'
    market_price = 1234
    expected_before = 16
    expected_after = market_price
    assert_changes card_name, market_price, expected_before, expected_after
  end

  def test_forgets_maindeck_prices
    card_name = 'Abandon Hope'
    market_price = 1234
    expected_before = 21
    expected_after = nil
    assert_changes card_name, market_price, expected_before, expected_after
  end

  def test_forgets_unlisted_prices
    card_name = 'Abrupt Decay'
    market_price = 1425
    expected_before = 1325
    expected_after = nil
    assert_changes card_name, market_price, expected_before, expected_after
  end

  def test_handles_market_error
    card_name = 'Forest'
    market_price = -> (_){ raise MarketParseException }
    expected_before = 16
    expected_after = 16
    assert_changes card_name, market_price, expected_before, expected_after
  end
end
