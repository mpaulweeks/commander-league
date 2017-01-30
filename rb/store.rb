
require 'json'
require_relative 'file_path'

class Store

  def initialize(year=nil)
    @year = year || "2016"
  end

  def users_path
    FilePath.users
  end
  def prices_path
    FilePath.prices
  end

  USER = 'user'
  STATUS = 'status'
  WALLET = 'wallet'
  CARD = 'card'

  def Store.now_str
    now_time.inspect
  end

  def Store.now_time
    Time.new
  end

  def glass_database!()
    users_hash = {
      Store::USER => {},
      Store::STATUS => {},
      Store::WALLET => {},
    }
    File.open(self.users_path, "w") do |f|
      f.write(users_hash.to_json)
    end
    prices_hash = {
      Store::CARD => {}
    }
    File.open(self.prices_path, "w") do |f|
      f.write(prices_hash.to_json)
    end
  end

  def load_users
    db_file = File.read(self.users_path)
    db_hash = JSON.parse(db_file)
    return db_hash
  end

  def load_prices
    db_file = File.read(self.prices_path)
    db_hash = JSON.parse(db_file)
    return db_hash
  end

  def load_database
    self.load_users.merge(self.load_prices)
  end

  def update_users!(new_hash)
    db_hash = load_users
    [USER, STATUS, WALLET].each do |key|
      if new_hash.has_key?(key)
        db_hash[key] = db_hash[key].merge(new_hash[key])
      end
    end
    File.open(self.users_path, "w") do |f|
      f.write(db_hash.to_json)
    end
  end

  def update_prices!(new_hash)
    db_hash = load_prices
    [CARD].each do |key|
      if new_hash.has_key?(key)
        db_hash[key] = db_hash[key].merge(new_hash[key])
      end
    end
    File.open(self.prices_path, "w") do |f|
      f.write(db_hash.to_json)
    end
  end

  def update_database!(new_hash)
    update_users!(new_hash)
    update_prices!(new_hash)
  end

  def insert_statuses!(user_slug, statuses)
    db_hash = load_users()
    db_hash[STATUS][user_slug].push(*statuses)
    File.open(self.users_path, "w") do |f|
      f.write(db_hash.to_json)
    end
  end

  def insert_wallet!(user_slug, wallet_entry)
    db_hash = load_users()
    db_hash[WALLET][user_slug].push(wallet_entry)
    File.open(self.users_path, "w") do |f|
      f.write(db_hash.to_json)
    end
  end

  def load_all_cards()
    all_cards_file = File.read(FilePath.all_cards)
    all_cards_hash = JSON.parse(all_cards_file)
    return all_cards_hash
  end

  def load_multiverse()
    multiverse_file = File.read(FilePath.multiverse_ids)
    multiverse_hash = JSON.parse(multiverse_file)
    return multiverse_hash
  end
end
