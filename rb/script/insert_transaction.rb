
require_relative '../store'

def insert_transaction(delta)
  delta = delta / 1.0

  puts "Inserting wallet transaction: %s" % delta

  db_cache = Store.load_database
  db_cache[Store::USER].each do |user_slug, user|
    wallet_entry = {
      :user_slug => user_slug,
      :delta => delta,
      :timestamp => Store.now_str,
    }
    Store.insert_wallet!(user_slug, wallet_entry)
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "Wallet transaction to insert: "
  delta = gets.chomp.to_i
  insert_transaction delta
end
