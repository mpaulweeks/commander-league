
require 'json'


module Store
  @DATABASE_PATH = 'json/database.json'

  USER = 'user'
  STATUS = 'status'
  CARD = 'card'
  WALLET = 'wallet'
  @KEYS = [USER, CARD, STATUS, WALLET]

  def Store.now
    Time.new.inspect
  end

  def Store.glass_database!()
    db_hash = {
      Store::USER => {},
      Store::CARD => {},
      Store::STATUS => {},
      Store::WALLET => {},
    }
    File.open(@DATABASE_PATH, "w") do |f|
      f.write(db_hash.to_json)
    end
  end

  def Store.load_database()
    db_file = File.read(@DATABASE_PATH)
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
    File.open(@DATABASE_PATH, "w") do |f|
      f.write(db_hash.to_json)
    end
  end

  def Store.insert_status!(status_hash)
    user_slug = status_hash[:user_slug]
    db_hash = load_database()
    db_hash[STATUS][user_slug].push(status_hash)
    File.open(@DATABASE_PATH, "w") do |f|
      f.write(db_hash.to_json)
    end
  end

  def Store.load_all_cards()
    all_cards_file = File.read('json/AllCards.json')
    all_cards_hash = JSON.parse(all_cards_file)
    return all_cards_hash
  end

  def Store.load_multiverse()
    multiverse_file = File.read('json/multiverse_ids.json')
    multiverse_hash = JSON.parse(multiverse_file)
    return multiverse_hash
  end
end
