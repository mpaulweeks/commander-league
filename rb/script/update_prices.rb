
require 'set'
require 'time'

require_relative '../store'
require_relative '../repo'
require_relative '../market'

STALE_DAYS = 1
STALE_SECONDS = STALE_DAYS*60*60*24

BATCH_MAX = 10

def update_prices
  puts "Running price updater..."

  cutoff = (Store.now_time - STALE_SECONDS).inspect

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
        if card[:sideboard] > 0
          cards_to_update.add(card_name)
        end
      end
    end
  end

  forgotten = 0
  cards = {}
  cards_needing_price = {}
  cards_with_prices.each do |card_name|
    card = db_cache[Store::CARD][card_name]
    if card['price_fetched'] < cutoff
      if cards_to_update.include? card_name
        cards_needing_price[card_name] = card
      else
        card['price'] = nil
        card['price_fetched'] = nil
        forgotten += 1
        cards[card_name] = card
      end
    end
  end

  update_requests = 0
  cards_needing_price.each do |card_name, card|
    if update_requests < BATCH_MAX
      begin
        card['price'] = Market.get_price(card_name)
      rescue MarketException
        puts "[ERROR] failed to lookup market price for %s" % card_name
      end
      card['price_fetched'] = Store.now_str
      update_requests += 1
      cards[card_name] = card
    end
  end

  puts "Prices updated: %s" % update_requests
  puts "Prices forgotten: %s" % forgotten

  if cards.size > 0
    store_hash = {
      Store::CARD => cards,
    }
    Store.update_database!(store_hash)
  end
end

if __FILE__ == $PROGRAM_NAME
  update_prices()
end
