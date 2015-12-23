
require 'set'
require 'time'

require_relative 'store'
require_relative 'repo'
require_relative 'market'

STALE_DAYS = 7
STALE_SECONDS = STALE_DAYS*60*60*24

def update_prices
  cutoff = (Time.parse(Store.now) - STALE_SECONDS).inspect

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

  cards = {}
  cards_with_prices.each do |card_name|
    card = db_cache[Store::CARD][card_name]
    if card['price_fetched'] < cutoff
      if cards_to_update.include? card_name
        card['price'] = Market.get_price(card_name)
        card['price_fetched'] = Store.now
      else
        card['price'] = nil
        card['price_fetched'] = nil
      end
      cards[card_name] = card
    end
  end

  store_hash = {
    Store::CARD => cards,
  }
  Store.update_database!(store_hash)
end

update_prices()
