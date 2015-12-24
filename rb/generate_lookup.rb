
require 'json'

def _add_card(lookup_hash, card)
  card_name = card['name']
  lookup_hash[card_name] = {
    :name => card_name,
    :colorIdentity => card['colorIdentity'] || [],
  }
end

def generate_lookup()
  all_cards_file = File.read('json/AllCards-x.json')
  all_cards_hash = JSON.parse(all_cards_file)

  lookup_hash = {}
  all_cards_hash.each do |card_name, card|
    if card.include? 'legalities'
      legalities = card['legalities']
      legalities.each do |legal_hash|
        if legal_hash['format'] == 'Commander' && legal_hash['legality'] == 'Legal'
          _add_card(lookup_hash, card)
        end
      end
    elsif card['printings'].include? 'C15'
      # temp workaround while MTGJson is stale
      _add_card(lookup_hash, card)
    end
  end

  File.open('json/lookup.json', "w") do |f|
    f.write(lookup_hash.to_json)
  end
end

generate_lookup()
