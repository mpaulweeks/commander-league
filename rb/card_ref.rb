
require_relative 'store'

class CardRef

  def initialize
    @all_cards = Store.load_all_cards
  end

  def get_card(card_name)
    unless @all_cards.has_key? card_name
      raise "Card not found: [%s]" % card_name
    end
    return @all_cards[card_name]
  end

  def has_card?(card_name)
    return @all_cards.has_key? card_name
  end
end
