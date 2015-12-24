
require 'json'

def generate_lookup()
  all_cards_file = File.read('json/AllCards-x.json')
  all_cards_hash = JSON.parse(all_cards_file)

  lookup_hash = {}
  all_cards_hash.each do |card_name, card|
    if card.include? 'legalities'
      legalities = card['legalities']
      legalities.each do |legal_hash|
        if legal_hash['format'] == 'Commander' && legal_hash['legality'] == 'Legal'
          lookup_hash[card_name] = {
            :name => card_name,
            :colorIdentity => card['colorIdentity'] || [],
          }
        end
      end
    end
  end

  File.open('json/lookup.json', "w") do |f|
    f.write(lookup_hash.to_json)
  end
end

generate_lookup()
