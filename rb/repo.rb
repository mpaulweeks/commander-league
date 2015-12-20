
require_relative 'store'

module Repo

  def Repo.load_user_cards(user_slug)
    db_cache = Store.load_database()

    out_status = {}
    db_cache[Store::KEY_STATUS][user_slug].each do |cs|
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
    db_cards = db_cache[Store::KEY_CARD]
    out_status.each do |card_name, card_status|
      card = db_cards[card_name].merge({
        :maindeck => card_status['maindeck'],
        :sideboard => card_status['sideboard'],
      })
      out_cards[card_name] = card
    end
    
    out_hash = {"user_id" => user_slug, "cards" => out_cards}
    return out_hash
  end

  def Repo.save_swap(view_binder)
    db_cache = Store.load_database()

    user_slug = view_binder['user_slug']
    old_binder = load_binder(user_slug)
    new_binder = view_binder['cards']

    # todo
  end
end

puts Repo.load_user_cards('mpw')
