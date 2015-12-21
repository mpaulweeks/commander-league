
require_relative 'store'

class Oracle

  def initialize
    @all_cards = Store.load_all_cards()
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

  def add_meta_data(cards)
    cards.each do |card|
      card_meta = all_cards[card.name]
      card[:category] = determine_category(card_meta)
    end
  end
end
