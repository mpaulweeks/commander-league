
require 'json'


def loadAllCards()
  all_cards_file = File.read('json/AllCards.json')
  all_cards_hash = JSON.parse(all_cards_file)
  return all_cards_hash
end

puts loadAllCards()
