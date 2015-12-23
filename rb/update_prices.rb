
require 'set'

require_relative 'store'
require_relative 'repo'
require_relative 'market'

STALE_DAYS = 7

def update_prices
  # cutoff = Store.now - STALE_DAYS
  cutoff = Store.now

  cards_with_prices = Set.new
  cards_to_update = Set.new
  db_cache = Store.load_database()
  db_cache[Store::CARD].each do |card_name, card|
    if card['price'] != nil
      cards_with_prices.add(card_name)
    end
  end
  db_cache[Store::USER].each do |user_slug, user|
    current_cards = Repo.load_cards(db_cache, user_slug)
    current_cards.each do |card_name, card|
      if cards_with_prices.include? card_name
        cards_to_update.add(card_name)
      end
    end
  end
  cards_to_ignore = cards_with_prices - cards_to_update

  cards = {}
  cards_to_ignore.each do |card_name|
    card = db_cache[Store::CARD][card_name]
    card['price'] = nil
    card['price_fetched'] = nil
    cards[card_name] = card
  end
  cards_to_update.each do |card_name|
    card = db_cache[Store::CARD][card_name]
    if card['price_fetched'] < cutoff
      card['price'] = Market.get_price(card_name)
      card['price_fetched'] = Store.now
      cards[card_name] = card
    end
  end
end

update_prices()
