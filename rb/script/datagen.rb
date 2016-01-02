
require_relative '../store'
require_relative '../repo'

USER_DATA = {
  :eliah => {:name => 'Eliah', :colors => ['U','G'], :deck => 'simic'},
  :qwerty => {:name => 'Patrick', :colors => ['W','B'], :deck => 'orzhov'},
  :mpw => {:name => 'M. Paul', :colors => ['B','G'], :deck => 'golgari'},
  :gant => {:name => 'GantMan', :colors => ['W','R'], :deck => 'boros'},
  :edmond => {:name => 'Edmond', :colors => ['U','R'], :deck => 'izzet'},
}

def create_users
  user_hash = {}
  wallet_hash = {}
  USER_DATA.each do |slug, user_data|
    user_hash[slug] = {
      :slug => slug,
      :name => user_data[:name],
      :colors => user_data[:colors],
    }
    wallet_hash[slug] = [{
      :user_slug => slug,
      :delta => 5.0,
      :timestamp => Store.now_str,
    }]
  end
  db_hash = {
    Store::USER => user_hash,
    Store::WALLET => wallet_hash,
  }
  Store.update_database!(db_hash)
end

def create_decks()
  all_cards = Store.load_all_cards()
  all_cards_lower = Hash[all_cards.map{|card_name, card| [card_name.downcase, card]}]

  status_hash = {}
  now = Store.now_str

  card_hash = {}
  USER_DATA.each do |user_slug, user_data|
    file_name = user_data[:deck]
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
      card_hash[card_name] = {
        :name => card_name,
        :price => nil,
        :price_fetched => nil,
      }
    end
    status_hash[user_slug] = card_statuses
  end

  db_hash = {
    Store::CARD => card_hash,
    Store::STATUS => status_hash,
  }
  Store.update_database!(db_hash)
end

def main()
  Store.glass_database!()
  create_users()
  create_decks()
  # Repo.create_statuses!('mpw', [
  #   {'name' => 'Borderland Ranger', 'maindeck' => 0, 'sideboard' => 1},
  #   {'name' => 'Sylvan Ranger', 'maindeck' => 0, 'sideboard' => 1},
  # ])
end

main()
