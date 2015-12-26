
require 'set'

require_relative 'store'
require_relative 'market'

module Repo

  def Repo.load_user_slugs
    db_cache = Store.load_database
    return db_cache[Store::USER].collect{ |user_slug, hash| user_slug }
  end

  def Repo.load_user_info(db_cache, user_slug)
    user = db_cache[Store::USER][user_slug]
    balance = 0.0
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

  def Repo.load_cards(db_cache, user_slug)
    out_status = {}
    was_maindeck = Set.new
    db_cache[Store::STATUS][user_slug].each do |cs|
      card_name = cs["card_name"]
      is_latest = true # && cs["timestamp"] < timestamp
      if out_status.has_key?(cs["status"])
        is_latest = out_status[card_name]["timestamp"] < cs["timestamp"]
      end
      if is_latest
        out_status[card_name] = cs
      end
      if cs["maindeck"] > 0
        was_maindeck.add(card_name)
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

  def Repo.load_user_cards(user_slug)
    db_cache = Store.load_database()
    user_hash = Repo.load_user_info(db_cache, user_slug)
    card_hash = Repo.load_cards(db_cache, user_slug)
    out_hash = {:user => user_hash, :cards => card_hash}
    return out_hash
  end

  def self.ensure_card_exists(db_cache, card_name)
    card_hash = db_cache[Store::CARD][card_name]
    if not card_hash
      card_hash = {
        :name => card_name,
        'price' => nil,
        'price_fetched' => nil,
      }
    end
    if card_hash['price'] == nil
      card_hash['price'] = Market.get_price(card_name)
      card_hash['price_fetched'] = Store.now
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
    old_user = Repo.load_user_info(db_cache, user_slug)
    old_cards = Repo.load_cards(db_cache, user_slug)
    to_save = []
    cards_added = 0
    balance = 0.0
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
    if balance > 0.0
      wallet_entry = {
        :user_slug => user_slug,
        :delta => 0.0 - balance,
        :timestamp => Store.now,
      }
      Store.insert_wallet!(user_slug, wallet_entry)
    end

    # refresh db cache, load current versions
    db_cache = Store.load_database
    refreshed_cards = Repo.load_cards(db_cache, user_slug)
    updated_cards = {}
    to_save.each do |status_hash|
      card_name = status_hash[:card_name]
      updated_cards[card_name] = refreshed_cards[card_name]
    end
    updated_data = {
      :cards => updated_cards
    }
    if balance > 0.0
      updated_data[:user] = Repo.load_user_info(db_cache, user_slug)
    end
    return updated_data
  end

end
