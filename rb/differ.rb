
require 'time'

require_relative 'store'
require_relative 'repo'

module Differ

  def self.get_epoch(db_cache, user_slug)
    epoch = Store.now_time
    db_cache[Store::STATUS][user_slug].each do |cs|
      cs_timestamp = Time.parse(cs["timestamp"])
      if cs_timestamp < epoch
        epoch = cs_timestamp
      end
    end
    return epoch
  end

  def Differ.get_diff(user_slug, from_str, to_str)
    db_cache = Store.load_database

    from_time = from_str ? Time.parse(from_str) : self.get_epoch(db_cache, user_slug)
    to_time = to_str ? Time.parse(to_str) : Store.now_time

    from_cards = Repo.load_cards(db_cache, user_slug, from_time)
    to_cards = Repo.load_cards(db_cache, user_slug, to_time)

    cards_out = {}

    to_cards.each do |card_name, new_info|
      old_info = from_cards[card_name]
      added = 0
      if old_info == nil
        added = new_info[:maindeck]
      else
        added = new_info[:maindeck] - old_info[:maindeck]
      end
      cards_out[card_name] = {
        :name => card_name,
        :added => added,
      }
    end
    from_cards.each do |card_name, old_info|
      if not cards_out.has_key? card_name
        added = 0 - old_info[:maindeck]
        cards_out[cards_name] = {
          :name => card_name,
          :added => added,
        }
      end
    end

    user_hash = Repo.load_user_info(db_cache, user_slug)
    out_hash = {:user => user_hash, :cards => cards_out}
    return out_hash
  end

end
