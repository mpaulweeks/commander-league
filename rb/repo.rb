
require_relative 'store'

module Repo

  def self.load_user_info(db_cache, user_slug)
    user = db_cache[Store::USER][user_slug]
    balance = 0
    db_cache[Store::WALLET][user_slug].each do |transaction|
      balance += transaction[:delta]
    end
    user_hash = {
      :slug => user_slug,
      :name => user['name'],
      :balance => balance,
    }
  end

  def self.load_cards(db_cache, user_slug)
    out_status = {}
    db_cache[Store::STATUS][user_slug].each do |cs|
      card_name = cs["card_name"]
      is_latest = true # && cs["timestamp"] < timestamp
      if out_status.has_key?(cs["status"])
        is_latest = out_status[card_name]["timestamp"] < cs["timestamp"]
      end
      if is_latest
        out_status[card_name] = cs
      end
    end

    out_cards = {}
    db_cards = db_cache[Store::CARD]
    out_status.each do |card_name, card_status|
      card = db_cards[card_name].merge({
        :maindeck => card_status['maindeck'],
        :sideboard => card_status['sideboard'],
        :maindeck_swap => 0,
        :sideboard_swap => 0,
      })
      out_cards[card_name] = card
    end

    return out_cards
  end

  def Repo.load_user_cards(user_slug)
    db_cache = Store.load_database()
    user_hash = self.load_user_info(db_cache, user_slug)
    card_hash = self.load_cards(db_cache, user_slug)
    out_hash = {:user => user_hash, :cards => card_hash}
    return out_hash
  end

  def self.ensure_card_exists(db_cache, card_name)
    card_hash = db_cache[Store::CARD][card_name]
    if not card_hash
      # fetch price
      # price = 0
      # price_fetched = Store.now
      card_hash = {
        :name => card_name,
        :price => nil,
        :price_fetched => nil,
      }
      store_hash = {
        Store::CARD => {
          card_name => card_hash,
        }
      }
      Store.update_database!(store_hash)
    end
  end

  def self.is_valid_status?(status_hash)
    return (
      status_hash.has_key?('name') &&
      status_hash.has_key?('maindeck') &&
      status_hash.has_key?('sideboard')
    )
  end

  def Repo.create_statuses!(user_slug, statuses)
    db_cache = Store.load_database
    to_save = []
    statuses.each do |raw_status_hash|
      if not self.is_valid_status?(raw_status_hash)
        puts 'failed validation! %s' % raw_status_hash
        next
      end

      new_status_hash = {
        :user_slug => user_slug,
        :card_name => raw_status_hash['name'],
        :maindeck => raw_status_hash['maindeck'],
        :sideboard => raw_status_hash['sideboard'],
        :timestamp => Store.now,
      }
      to_save.push(new_status_hash)
      ensure_card_exists(db_cache, new_status_hash[:card_name])
    end
    Store.insert_statuses!(user_slug, to_save)

    refreshed_cards = Repo.load_user_cards(user_slug)[:cards]
    updated_cards = {}
    to_save.each do |status_hash|
      card_name = status_hash[:card_name]
      updated_cards[card_name] = refreshed_cards[card_name]
    end
    return updated_cards
  end

end

# puts Repo.load_user_cards('mpw')
