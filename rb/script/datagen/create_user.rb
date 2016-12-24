
require_relative '../../store'
require_relative '../../card_ref'
require_relative '../../repo'

DECK_FILES = {
  'simic' => {:colors => ['U','G'], :path => '2015/simic'},
  'orzhov' => {:colors => ['W','B'], :path => '2015/orzhov'},
  'golgari' => {:colors => ['B','G'], :path => '2015/golgari'},
  'boros' => {:colors => ['W','R'], :path => '2015/boros'},
  'izzet' => {:colors => ['U','R'], :path => '2015/izzet'},
  'atraxa' => {:colors => ['G', 'W', 'U', 'B'], :path => '2016/atraxa'},
  'breya' => {:colors => ['W', 'U', 'B', 'R'], :path => '2016/breya'},
  'kynaios' => {:colors => ['R', 'G', 'W', 'U'], :path => '2016/kynaios'},
  'saskia' => {:colors => ['B', 'R', 'G', 'W'], :path => '2016/saskia'},
  'yidris' => {:colors => ['U', 'B', 'R', 'G'], :path => '2016/yidris'},
}

def create_user(slug, name, deck_data, balance)
  user_hash = {}
  wallet_hash = {}
  user_hash[slug] = {
    :slug => slug,
    :name => name,
    :colors => deck_data[:colors],
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

def create_deck(user_slug, deck_data)
  card_ref = CardRef.new

  db_cache = Store.load_database

  status_hash = {}
  now = Store.now_str

  card_hash = {}
  card_statuses = Array.new
  file_path = "data/#{deck_data[:path]}.txt"
  file_text = File.readlines(file_path)
  file_text.each do |line|
    line = line.strip()
    if line.length == 0
      next
    end
    space = line.index(' ')
    quantity = Integer(line.slice(0..space))
    card_name = line.slice((space+1)..-1).gsub(' // ', '/')
    if not card_ref.has_card?(card_name)
      puts 'Card not found: %s' % card_name.downcase
      raise 'Aborting'
    end
    card = card_ref.get_card(card_name)
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
  # Store.glass_database!

  puts "Player slug: "
  slug = gets.chomp
  puts "Player name: "
  name = gets.chomp
  puts "Player deck: "
  deck_name = gets.chomp
  puts "Player balance: "
  balance = gets.chomp.to_i
  balance = 1000

  deck_data = DECK_FILES[deck_name]
  create_user slug, name, deck_data, balance
  create_deck slug, deck_data
end
