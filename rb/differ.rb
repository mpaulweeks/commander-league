
require 'set'
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

    added_names = Set.new
    removed_names = Set.new

    to_cards.each do |card_name, new_info|
      old_info = from_cards[card_name]
      if old_info == nil
        if new_info[:maindeck] > 0
          added_names.add(card_name)
        end
      elsif old_info[:maindeck] < new_info[:maindeck]
        added_names.add(card_name)
      elsif old_info[:maindeck] > new_info[:maindeck]
        removed_names.add(card_name)
      end
    end
    from_cards.each do |card_name, old_info|
      if not to_cards.has_key? card_name
        removed_names.add(card_name)
      end
    end

    return {
      :added => added_names,
      :removed => removed_names,
    }
  end

end

puts Differ.get_diff('edmond', nil, nil)
