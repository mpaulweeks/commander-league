
require 'json'


module Store
  @DATABASE_PATH = 'json/database.json'

  KEY_USER = 'user'
  KEY_STATUS = 'status'
  KEY_CARD = 'card'
  @KEYS = [KEY_USER, KEY_CARD, KEY_STATUS]

  def Store.glass_database!()
    db_hash = {
      Store::KEY_USER => {},
      Store::KEY_CARD => {},
      Store::KEY_STATUS => {},
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

  def Store.update_database(new_hash)
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

  def Store.load_all_cards()
    all_cards_file = File.read('json/AllCards.json')
    all_cards_hash = JSON.parse(all_cards_file)
    return all_cards_hash
  end
end
