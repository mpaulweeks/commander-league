
require_relative 'store'

class CardRef

  def initialize(store)
    @store = store
    @all_cards = @store.load_all_cards
  end

  def get_card(card_name)
    card = lookup_card card_name
    unless card
      raise "Card not found: [%s]" % card_name
    end
    return card
  end

  def has_card?(card_name)
    return !lookup_card(card_name).nil?
  end

  def lookup_card(card_name)
    card = @all_cards[card_name]
    if card.nil?
      if card_name.include? '/'
        a_name, b_name = card_name.split('/')
        a_card = @all_cards[a_name]
        if !a_card.nil? && a_card['names'] == [a_name, b_name]
          out_card = a_card.clone
          out_card['name'] = card_name
          return out_card
        end
      end
      return nil
    end
    if card['layout'] == 'split'
      return nil
    end
    return card
  end
  private :lookup_card

end
