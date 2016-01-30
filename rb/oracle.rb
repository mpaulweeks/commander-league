
require_relative 'store'

class Oracle

  attr_reader :all_cards, :multiverse

  def initialize
    @all_cards = Store.load_all_cards
    @multiverse = Store.load_multiverse
  end

  def determine_category(card_meta)
    types = card_meta['types']
    if types.include? 'Land'
      return :Land
    end
    if types.include? 'Creature'
      return :Creature
    end
    return :Spell
  end

  def add_card_meta!(cards)
    cards.each do |card_name, card|
      unless self.all_cards.has_key? card_name
        raise "Card not found: [%s]" % card_name
      end
      card_meta = self.all_cards[card_name]
      card[:category] = determine_category(card_meta)
      card[:multiverse] = self.multiverse[card_name]
    end
  end
end
