
require "minitest/autorun"
require_relative '../script/update_prices'

require 'json'

class UpdatePricesTest < Minitest::Test

  def setup
    @test_path = 'rb/test/tmp/database.json'
    FileUtils.cp('json/test/database.json', @test_path)
  end

  def assert_changes(card_name, market_price, expected_before, expected_after)
    FilePath.stub :database, @test_path do
      Market.stub :get_price, market_price do
        before_db = Store.load_database
        assert_equal expected_before, before_db[Store::CARD][card_name]['price']
        update_prices
        after_db = Store.load_database
        assert_equal expected_after, after_db[Store::CARD][card_name]['price']
      end
    end
  end

  def test_updates_sideboard_prices
    card_name = 'Forest'
    market_price = 12.34
    expected_before = 0.16
    expected_after = market_price
    assert_changes card_name, market_price, expected_before, expected_after
  end

  def test_forgets_maindeck_prices
    card_name = 'Abandon Hope'
    market_price = 12.34
    expected_before = 0.21
    expected_after = nil
    assert_changes card_name, market_price, expected_before, expected_after
  end

  def test_forgets_unlisted_prices
    card_name = 'Abrupt Decay'
    market_price = 14.25
    expected_before = 13.25
    expected_after = nil
    assert_changes card_name, market_price, expected_before, expected_after
  end
end