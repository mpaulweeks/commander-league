
require_relative 'store'

STATUS_IN_MAINDECK = 'maindeck'
STATUS_IN_SIDEBOARD = 'sideboard'

class Repository
  DB_CACHE = {}

  def initialize()
    refresh_cache()
  end

  def refresh_cache()
    DB_CACHE = load_database()
  end

  def load_binder(user_slug)
    out_status = {}
    DB_CACHE[KEY_STATUS][user_slug].each do |cs|
      card_name = cs["card_name"]
      is_latest = true # && cs["timestamp"] < timestamp
      if out_status.has_key?(cs["status"])
        is_latest = out_status[card_name]["timestamp"]] < cs["timestamp"]
      end
      if is_latest
        out_status[card_name] = cs
      end
    end

    out_cards = {STATUS_IN_MAINDECK => [], STATUS_IN_SIDEBOARD => []}
    out_status.each do |card_name, card_status|
      card = DB_CACHE[KEY_CARD][card_name]
      out_cards[card_status][card_name] = card
    end
    
    out_hash = {"user_id" => user_slug, "cards" => out_cards}
    return out_hash
  end

  def save_binder(view_binder)
    user_slug = view_binder['user_slug']
    old_binder = load_binder(user_slug)
    new_binder = view_binder['cards']
  end
end