
require_relative 'store'

STATUS_IN_MAINDECK = 'maindeck'
STATUS_IN_SIDEBOARD = 'sideboard'

def Repository()
  DB_CACHE = {}

  def refresh_cache()
    DB_CACHE = load_database()
  end

  refresh_cache()

  def load_binder(user_slug)
    out_status = {}
    DB_CACHE[KEY_STATUS][user_slug].each do |cs|
      card_name = cs["card_name"]
      is_current = true
      if out_status.has_key?(cs["status"])
        is_current = out_status[card_name]["timestamp"]] < cs["timestamp"]
      end
      if is_current
        out_status[card_name] = cs
      end
    end

    out_cards = {"maindeck" => [], "sideboard" => []}
    # process out_status
    
    out_hash = {"user_id" => user_slug, "cards" => out_cards}
    return out_hash
  end
