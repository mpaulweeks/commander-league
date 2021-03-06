
require 'set'
require 'time'

require_relative 'store'
require_relative 'card_ref'
require_relative 'market'

class IllegalCardException < Exception
end

class InvalidStatusException < Exception
end

class Repo

  def initialize(card_ref=nil)
    @card_ref = card_ref || CardRef.new
    @stale_users = Store.load_database()[Store::USER].values
  end

  def load_user_slugs
    db_cache = Store.load_database
    return db_cache[Store::USER].collect{ |user_slug, hash| user_slug }
  end

  def get_stale_users
    return @stale_users
  end

  def load_user_info(db_cache, user_slug)
    user = db_cache[Store::USER][user_slug]
    balance = 0
    db_cache[Store::WALLET][user_slug].each do |transaction|
      balance += transaction['delta']
    end
    user_hash = {
      :slug => user_slug,
      :name => user['name'],
      :colors => user['colors'],
      :balance => balance,
    }
  end

  def load_cards(db_cache, user_slug, cutoff_timestamp=nil)
    out_status = {}
    was_maindeck = Set.new
    cutoff_timestamp = cutoff_timestamp || Store.now_time
    db_cache[Store::STATUS][user_slug].each do |cs|
      card_name = cs["card_name"]
      cs_timestamp = Time.parse(cs["timestamp"])
      if cs_timestamp <= cutoff_timestamp
        is_latest = true
        if out_status.has_key? card_name
          is_latest = Time.parse(out_status[card_name]["timestamp"]) < cs_timestamp
        end
        if is_latest
          out_status[card_name] = cs
        end

        if cs["maindeck"] > 0
          was_maindeck.add(card_name)
        end
      end
    end

    out_cards = {}
    db_cards = db_cache[Store::CARD]
    out_status.each do |card_name, card_status|
      card_hash = db_cards[card_name]
      out_card = {
        :name => card_hash['name'],
        :price => card_hash['price'],
        :maindeck => card_status['maindeck'],
        :sideboard => card_status['sideboard'],
      }
      if was_maindeck.include? card_name
        out_card[:price] = nil
      end
      out_cards[card_name] = out_card
    end

    return out_cards
  end

  def load_user_cards(user_slug, cutoff_timestamp=nil)
    db_cache = Store.load_database()
    user_hash = self.load_user_info(db_cache, user_slug)
    card_hash = self.load_cards(db_cache, user_slug, cutoff_timestamp)
    out_hash = {:user => user_hash, :cards => card_hash}
    return out_hash
  end

  def ensure_card_exists(db_cache, card_name)
    card_hash = db_cache[Store::CARD][card_name]
    unless card_hash
      unless @card_ref.has_card? card_name
        raise IllegalCardException, card_name
      end
      card_hash = {
        :name => card_name,
        'price' => nil,
        'price_fetched' => nil,
      }
    end
    if card_hash['price'] == nil
      card_hash['price'] = Market.get_price(card_name)
      card_hash['price_fetched'] = Store.now_str
      store_hash = {
        Store::CARD => {
          card_name => card_hash,
        }
      }
      Store.update_database!(store_hash)
    end
  end

  def is_valid_status?(status_hash)
    return (
      status_hash.has_key?('name') &&
      status_hash.has_key?('maindeck') &&
      status_hash.has_key?('sideboard')
    )
  end

  def create_statuses!(user_slug, statuses)
    db_cache = Store.load_database
    old_user = self.load_user_info(db_cache, user_slug)
    old_cards = self.load_cards(db_cache, user_slug)
    to_save = []
    cards_added = 0
    balance = 0
    statuses.each do |raw_status_hash|
      if not self.is_valid_status?(raw_status_hash)
        raise InvalidStatusException, raw_status_hash
      end

      new_status_hash = {
        :user_slug => user_slug,
        :card_name => raw_status_hash['name'],
        :maindeck => raw_status_hash['maindeck'],
        :sideboard => raw_status_hash['sideboard'],
        :timestamp => Store.now_str,
      }
      to_save.push(new_status_hash)
      ensure_card_exists(db_cache, new_status_hash[:card_name])

      card_name = new_status_hash[:card_name]
      if old_cards.include? card_name
        old_card_hash = old_cards[card_name]
        cards_added += new_status_hash[:maindeck] - old_card_hash[:maindeck]
        if old_card_hash[:price] != nil
          balance += old_card_hash[:price] * (new_status_hash[:maindeck] - old_card_hash[:maindeck])
        end
      end
    end

    if balance > old_user[:balance]
      raise ArgumentError.new("failed! too high a balance. #{balance} > #{old_user[:balance]}")
    end
    if cards_added != 0
      raise ArgumentError.new("failed! num cards != removed. added: #{cards_added}")
    end
    Store.insert_statuses!(user_slug, to_save)
    if balance > 0
      wallet_entry = {
        :user_slug => user_slug,
        :delta => 0 - balance,
        :timestamp => Store.now_str,
      }
      Store.insert_wallet!(user_slug, wallet_entry)
    end

    # refresh db cache, load current versions
    db_cache = Store.load_database
    refreshed_cards = self.load_cards(db_cache, user_slug)
    updated_cards = {}
    to_save.each do |status_hash|
      card_name = status_hash[:card_name]
      updated_cards[card_name] = refreshed_cards[card_name]
    end
    updated_data = {
      :cards => updated_cards
    }
    if balance > 0
      updated_data[:user] = self.load_user_info(db_cache, user_slug)
    end
    return updated_data
  end

end
