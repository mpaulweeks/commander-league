
require "minitest/autorun"
require_relative '../repo'

require 'json'

class RepoTest < Minitest::Test

  def setup
    @test_path = 'rb/test/tmp/database.json'
    @market_price = 25
    @repo = Repo.new
    FileUtils.cp('json/test/database.json', @test_path)
  end

  def insert_statuses(user_slug, statuses)
    FilePath.stub :database, @test_path do
      Market.stub :get_price, @market_price do
        return @repo.create_statuses!(user_slug, statuses)
      end
    end
  end

  def assert_status_inserted(card_name, maindeck, sideboard)
    user_slug = 'mpw'
    statuses = [{
      'name' => card_name,
      'maindeck' => maindeck,
      'sideboard' => sideboard,
    }]
    res = insert_statuses(user_slug, statuses)
    expected = {
      :name => card_name,
      :price => @market_price,
      :maindeck => maindeck,
      :sideboard => sideboard,
    }
    assert_equal res[:cards][card_name], expected
    FilePath.stub :database, @test_path do
      res = @repo.load_user_cards(user_slug)
    end
    assert_equal res[:cards][card_name], expected
  end

  def test_insert_maindeck
    assert_status_inserted 'Fog', 0, 1
  end

  def test_insert_maindeck_unicode
    assert_status_inserted 'Æther Burst', 0, 1
  end

  def test_insert_maindeck_fake
    assert_raises(IllegalCardException) {
      assert_status_inserted 'fart', 0, 1
    }
  end
end
