
require_relative 'store'
require_relative 'card_ref'

class Oracle

  attr_reader :card_ref, :multiverse

  def initialize(card_ref=nil)
    @card_ref = card_ref || CardRef.new
    @multiverse = Store.load_multiverse
    @categories = [
      'Land',
      'Creature',
      'Enchantment - Aura',
      'Enchantment',
      'Artifact - Equipment',
      'Artifact',
      'Planeswalker',
      'Sorcery',
      'Instant'
    ]
  end

  def determine_category(card_meta)
    types = card_meta['types']
    @categories.each do |category|
      types.each do |type|
        if (category.include? '-') && (card_meta.has_key? "subtypes")
          subtype = card_meta["subtypes"][0]
          if category == ("%s - %s" % [type, subtype])
            return category
          end
        elsif category == type
          return category
        end
      end
    end
    raise "Found an un-categorizable card! %s" % card_meta
  end

  def add_card_meta!(cards)
    cards.each do |card_name, card|
      card_meta = self.card_ref.get_card(card_name)
      card[:category] = determine_category(card_meta)
      card[:multiverse] = self.multiverse[card_name]
    end
  end
end
