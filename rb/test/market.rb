
require "minitest/autorun"
require_relative '../market'

require 'json'

class MarketTest < Minitest::Test

  def test_get_price
    assert 0 < Market.get_price('Masticore')
  end

  def test_url_fetch
    card_name = 'Masticore'
    url = COMBODECK_URL % card_name
    json_str = Market.fetch_url(url)

    json_dict = JSON.parse json_str
    matching_cards = []
    json_dict['Cards'].each do |card|
      matching_cards.push(card['CardName'])
    end

    assert_includes matching_cards, card_name
  end

  def test_combodeck_parse
    json_str = '{"Cards":[{"CardName":"Masticore","SetName":"Urza\u0027s Destiny","Side":0,"OtherSideCardName":null,"ManaCost":"{4}","Type":"Artifact Creature — Masticore","Text":"At the beginning of your upkeep, sacrifice Masticore unless you discard a card.\u003c/p\u003e\u003cp\u003e{2}: Masticore deals 1 damage to target creature.\u003c/p\u003e\u003cp\u003e{2}: Regenerate Masticore.","MultiverseId":13087,"PowerAndToughness":"4/4","Loyalty":null,"Color":"Colorless","Layout":"Normal","PriceInCents":169,"TcgPlayerUrl":"http://store.tcgplayer.com/magic/urzas-destiny/masticore?partner=COMBODECK","Sets":[{"SetName":"Urza\u0027s Destiny","Rarity":"Rare"},{"SetName":"From the Vault: Relics","Rarity":"Mythic Rare"},{"SetName":"Vintage Masters","Rarity":"Rare"}]}]}'
    price = Market.parse_combodeck_json('Masticore', json_str)
    assert_equal price, 169
  end
end
