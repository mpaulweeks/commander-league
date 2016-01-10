
require_relative '../store'

def fix_prices
  puts "Fixing prices..."

  db_cache = Store.load_database
  db_cache[Store::CARD].each do |card_name, card|
    price = card['price']
    if price.is_a? Float
      card['price'] = (price * 100).to_i
    end
  end
  db_cache[Store::WALLET].each do |user_slug, transactions|
    transactions.each do |trans|
      delta = trans['delta']
      if delta.is_a? Float
        trans['delta'] = (delta * 100).to_i
      end
    end
  end

  db_hash = {
    Store::CARD => db_cache[Store::CARD],
    Store::WALLET => db_cache[Store::WALLET],
  }
  Store.update_database!(db_hash)
end

if __FILE__ == $PROGRAM_NAME
  fix_prices
end
