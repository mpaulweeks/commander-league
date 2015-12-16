
require 'json'

DATABASE_PATH = 'json/database.json'
KEY_USER = 'user'
KEY_STATUS = 'status'
KEY_CARD = 'card'
KEYS = [KEY_USER, KEY_CARD, KEY_STATUS]

def load_database()
  db_file = File.read(DATABASE_PATH)
  db_hash = JSON.parse(db_file)
  return db_hash
end

def save_database(new_hash)
  db_hash = load_database()
  KEYS.each do |key|
    if new_hash.has_key?(key)
      db_hash[key] = db_hash[key].merge(new_hash[key])
    end
  end
  File.open(DATABASE_PATH, "w") do |f|
    f.write(db_hash.to_json)
  end
end
