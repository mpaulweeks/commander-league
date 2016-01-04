
require "minitest/autorun"
require_relative '../script/update_prices'

require 'json'

class UpdatePricesTest < Minitest::Test

  def setup
    @test_path = 'rb/test/tmp/database.json'
    FileUtils.cp('json/test/database.json', @test_path)
  end

  def assert_changes(card_name, before_price, after_price)
    FilePath.stub :database, @test_path do
      Market.stub :get_price, after_price do
        before_db = Store.load_database
        assert_equal before_price, before_db[Store::CARD][card_name]['price']
        update_prices()
        after_db = Store.load_database
        assert_equal after_price, after_db[Store::CARD][card_name]['price']
      end
    end
  end

  def test_updates_prices
    card_name = 'Abandon Hope'
    before_price = 0.21
    after_price = 12.34
    assert_changes card_name, before_price, after_price
  end

  def test_forgets_prices
    card_name = 'Abrupt Decay'
    before_price = 13.25
    after_price = nil
    assert_changes card_name, before_price, after_price
  end
end