
require 'json'
require_relative 'file_path'

def _add_card(lookup_array, card)
  card_name = card['name']
  lookup_array.push([card_name, card['colorIdentity'] || []])
end

def generate_lookup()
  all_cards_file = File.read(FilePath.all_cards_extras)
  all_cards_hash = JSON.parse(all_cards_file)

  lookup_array = []
  all_cards_hash.each do |card_name, card|
    if card.include? 'legalities'
      legalities = card['legalities']
      legalities.each do |legal_hash|
        if legal_hash['format'] == 'Commander' && legal_hash['legality'] == 'Legal'
          _add_card(lookup_array, card)
        end
      end
    elsif card['printings'].include? 'C15'
      # temp workaround while MTGJson is stale
      _add_card(lookup_array, card)
    end
  end

  File.open(FilePath.lookup, "w") do |f|
    f.write(lookup_array.to_json)
  end
end

generate_lookup()
