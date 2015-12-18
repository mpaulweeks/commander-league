
require_relative 'store'
require_relative 'repo'

USER_NAMES = [
  ['eliah', 'Eliah'],
  ['qwerty', 'Patrick'],
  ['mpw', 'M. Paul'],
  ['gant', 'Dan'],
  ['edmond', 'Edmond'],
]

USER_DECKS = {
  'eliah' => 'simic',
  'querty' => 'orzhov',
  'mpw' => 'golgari',
  'gant' => 'boros',
  'edmond' => 'izzet',
}

def create_users()
  def make_object(tuple)
    return {'slug' => tuple[0], 'name' => tuple[1]}
  end

  user_hash = Hash[USER_NAMES.map{|n| [n[0], make_object(n)]}]
  db_hash = {Store::KEY_USER => user_hash}
  Store.update_database(db_hash)
end

def create_decks()
  all_cards = Store.load_all_cards()
  all_cards_lower = Hash[all_cards.map{|card_name, card| [card_name.downcase, card]}]

  status_hash = {}
  now = Time.new.inspect

  USER_DECKS.each do |user_slug, file_name|
    card_statuses = Array.new
    file_path = 'data/' + file_name + '.txt'
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
        puts card_name.downcase
        next
      end
      card = all_cards_lower[card_name.downcase]
      card_status = {
        'user_slug' => user_slug,
        'card_name' => card['name'],
        'status_id' => STATUS_IN_MAINDECK,
        'timestamp' => now,
      }
      if quantity > 1
        card_status['quantity'] = quantity
      end
      card_statuses.push(card_status)
    end
    status_hash[user_slug] = card_statuses
  end

  db_hash = {Store::KEY_STATUS => status_hash}
  Store.update_database(db_hash)
end

def main()
  Store.glass_database!()
  create_users()
  create_decks()
end

main()