
require_relative 'store'
require_relative 'card_ref'

class Oracle

  attr_reader :card_ref, :multiverse

  def initialize(card_ref=nil)
    @card_ref = card_ref || CardRef.new
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
      card_meta = self.card_ref.get_card(card_name)
      card[:category] = determine_category(card_meta)
      card[:multiverse] = self.multiverse[card_name]
    end
  end
end
