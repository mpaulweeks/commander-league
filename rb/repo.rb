
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
        :from_maindeck => 0,
        :from_sideboard => 0,
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

  def Repo.modify_sideboard(user_slug, card_name, quantity)
    db_cache = Store.load_database()

    ensure_card_exists(db_cache, card_name)

    user_hash = self.load_cards(db_cache, user_slug)
    current_card = user_hash[card_name]
    new_status = {
      :user_slug => user_slug,
      :card_name => card_name,
      :maindeck => current_card ? current_card[:maindeck] : 0,
      :sideboard => quantity,
      :timestamp => Store.now,
    }
    Store.insert_status!(new_status)
  end

  def Repo.save_swap(view_binder)
    db_cache = Store.load_database()

    user_slug = view_binder['user']
    old_binder = load_binder(user_slug)
    new_binder = view_binder['cards']

    # todo
  end
end

# puts Repo.load_user_cards('mpw')
