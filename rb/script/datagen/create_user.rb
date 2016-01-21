
require_relative '../../store'
require_relative '../../repo'

DECK_FILES = [
  {:colors => Set.new(['U','G']), :deck => 'simic'},
  {:colors => Set.new(['W','B']), :deck => 'orzhov'},
  {:colors => Set.new(['B','G']), :deck => 'golgari'},
  {:colors => Set.new(['W','R']), :deck => 'boros'},
  {:colors => Set.new(['U','R']), :deck => 'izzet'},
]

def create_user(slug, name, colors, balance)
  user_hash = {}
  wallet_hash = {}
  user_hash[slug] = {
    :slug => slug,
    :name => name,
    :colors => colors,
  }
  wallet_hash[slug] = [{
    :user_slug => slug,
    :delta => balance,
    :timestamp => Store.now_str,
  }]
  db_hash = {
    Store::USER => user_hash,
    Store::WALLET => wallet_hash,
  }
  Store.update_database!(db_hash)
end

def create_deck(user_slug, file_name)
  all_cards = Store.load_all_cards()
  all_cards_lower = Hash[all_cards.map{|card_name, card| [card_name.downcase, card]}]
  db_cache = Store.load_database

  status_hash = {}
  now = Store.now_str

  card_hash = {}
  card_statuses = Array.new
  file_path = "data/#{file_name}.txt"
  file_text = File.readlines(file_path)
  file_text.each do |line|
    line = line.strip()
    if line.length == 0
      next
    end
    space = line.index(' ')
    quantity = Integer(line.slice(0..space))
    card_name = line.slice((space+1)..-1)
    if not all_cards_lower.has_key?(card_name.downcase)
      puts 'Card not found: %s' % card_name.downcase
      next
    end
    card = all_cards_lower[card_name.downcase]
    card_name = card['name']
    card_status = {
      :user_slug => user_slug,
      :card_name => card_name,
      :maindeck => quantity,
      :sideboard => 0,
      :timestamp => now,
    }
    card_statuses.push(card_status)
    unless db_cache[Store::CARD].has_key? card_name
      card_hash[card_name] = {
        :name => card_name,
        :price => nil,
        :price_fetched => nil,
      }
    end
  end
  status_hash[user_slug] = card_statuses

  puts "Cards inserted: %s" % card_hash.length
  puts "Statuses inserted: %s" % card_statuses.length
  db_hash = {
    Store::CARD => card_hash,
    Store::STATUS => status_hash,
  }
  Store.update_database!(db_hash)
end


if __FILE__ == $PROGRAM_NAME
  puts "Player slug: "
  slug = gets.chomp
  puts "Player name: "
  name = gets.chomp
  puts "Player colors: "
  colors = gets.chomp.split(',')
  puts "Player balance: "
  balance = gets.chomp.to_i
  create_user slug, name, colors, balance

  deck_file = ''
  DECK_FILES.each do |deck_hash|
    if deck_hash[:colors] == Set.new(colors)
      deck_file = deck_hash[:deck]
    end
  end
  create_deck slug, deck_file
end
