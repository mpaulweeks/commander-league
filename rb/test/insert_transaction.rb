
require "minitest/autorun"
require_relative '../file_path'
require_relative '../script/insert_transaction'
require_relative '../repo'

class InsertTransactionTest < Minitest::Test

  def setup
    @test_users = 'rb/test/tmp/users.json'
    FileUtils.cp(FilePath.test_users, @test_users)
  end

  def get_balance(repo)
    balance = {}
    db_cache = Store.load_database
    db_cache[Store::USER].each do |user_slug, user|
      user_info = repo.load_user_info(db_cache, user_slug)
      balance[user_slug] = user_info[:balance]
    end
    return balance
  end

  def test_insert_transaction
    FilePath.stub :users, @test_users do
    FilePath.stub :prices, FilePath.test_prices do
      repo = Repo.new
      before_balance = get_balance(repo)
      delta = -1234
      insert_transaction(delta)
      after_balance = get_balance(repo)
      expected_balance = {}
      after_balance.each do |user_slug, balance|
        expected_balance[user_slug] = before_balance[user_slug] + delta
      end
      refute_equal after_balance, before_balance
      assert_equal after_balance, expected_balance
    end
    end
  end
end
