
require "minitest/autorun"
require_relative '../file_path'
require_relative '../repo'

require 'json'

class RepoTest < Minitest::Test

  def setup
    @test_users = 'rb/test/tmp/users.json'
    @test_prices = 'rb/test/tmp/prices.json'
    @market_price = 25
    FileUtils.cp(FilePath.test_users, @test_users)
    FileUtils.cp(FilePath.test_prices, @test_prices)
  end

  def _insert_statuses(repo, user_slug, statuses)
    Market.stub :get_price, @market_price do
      return repo.create_statuses!(user_slug, statuses)
    end
  end

  def _assert_status_inserted(card_name, maindeck, sideboard)
    user_slug = 'mpw'
    statuses = [{
      'name' => card_name,
      'maindeck' => maindeck,
      'sideboard' => sideboard,
    }]
    expected = {
      :name => card_name,
      :price => @market_price,
      :maindeck => maindeck,
      :sideboard => sideboard,
    }
    FilePath.stub :users, @test_users do
    FilePath.stub :prices, @test_prices do
      repo = Repo.new
      res = _insert_statuses(repo, user_slug, statuses)
      assert_equal res[:cards][card_name], expected
      res = repo.load_user_cards(user_slug)
      assert_equal res[:cards][card_name], expected
    end
    end
  end

  def test_insert_maindeck
    _assert_status_inserted 'Fog', 0, 1
  end

  def test_insert_maindeck_unusual
    _assert_status_inserted 'Aether Burst', 0, 1
  end

  def test_insert_maindeck_fake
    assert_raises(IllegalCardException) {
      _assert_status_inserted 'fart', 0, 1
    }
  end
end
