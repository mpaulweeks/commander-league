
require 'json'
require_relative 'file_path'

module Store
  def self.database_path
    FilePath.database
  end

  USER = 'user'
  STATUS = 'status'
  CARD = 'card'
  WALLET = 'wallet'
  @KEYS = [USER, CARD, STATUS, WALLET]

  def Store.now_str
    Store.now_time.inspect
  end

  def Store.now_time
    Time.new
  end

  def Store.glass_database!()
    db_hash = {
      Store::USER => {},
      Store::CARD => {},
      Store::STATUS => {},
      Store::WALLET => {},
    }
    File.open(self.database_path, "w") do |f|
      f.write(db_hash.to_json)
    end
  end

  def Store.load_database()
    db_file = File.read(self.database_path)
    db_hash = JSON.parse(db_file)
    return db_hash
  end

  def Store.update_database!(new_hash)
    db_hash = load_database()
    @KEYS.each do |key|
      if new_hash.has_key?(key)
        db_hash[key] = db_hash[key].merge(new_hash[key])
      end
    end
    File.open(self.database_path, "w") do |f|
      f.write(db_hash.to_json)
    end
  end

  def Store.insert_statuses!(user_slug, statuses)
    db_hash = load_database()
    db_hash[STATUS][user_slug].push(*statuses)
    File.open(self.database_path, "w") do |f|
      f.write(db_hash.to_json)
    end
  end

  def Store.insert_wallet!(user_slug, wallet_entry)
    db_hash = load_database()
    db_hash[WALLET][user_slug].push(wallet_entry)
    File.open(self.database_path, "w") do |f|
      f.write(db_hash.to_json)
    end
  end

  def Store.load_all_cards()
    all_cards_file = File.read(FilePath.all_cards)
    all_cards_hash = JSON.parse(all_cards_file)
    return all_cards_hash
  end

  def Store.load_multiverse()
    multiverse_file = File.read(FilePath.multiverse_ids)
    multiverse_hash = JSON.parse(multiverse_file)
    return multiverse_hash
  end
end
