
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
    json_str = '{"Cards":[{"CardName":"Masticore","Side":0,"OtherSideCardName":null,"ManaCost":"{4}","Type":"Artifact Creature — Masticore","Text":"At the beginning of your upkeep, sacrifice Masticore unless you discard a card.\u003c/p\u003e\u003cp\u003e{2}: Masticore deals 1 damage to target creature.\u003c/p\u003e\u003cp\u003e{2}: Regenerate Masticore.","PowerAndToughness":"4/4","Loyalty":null,"Color":"Colorless","Layout":"Normal","Printings":[{"SetName":"Urza\u0027s Destiny","Rarity":"Rare","MultiverseId":13087,"PriceCentsPaper":169,"PriceCentsDigital":1,"AffiliateUrlPaper":"http://store.tcgplayer.com/magic/urzas-destiny/masticore?partner=COMBODECK","AffiliateUrlDigital":"https://www.cardhoarder.com/cards/12763?affiliate_id=combodeck"},{"SetName":"From the Vault: Relics","Rarity":"Mythic Rare","MultiverseId":212629,"PriceCentsPaper":173,"PriceCentsDigital":0,"AffiliateUrlPaper":"http://store.tcgplayer.com/magic/from-the-vault-relics/masticore?partner=COMBODECK","AffiliateUrlDigital":"https://www.cardhoarder.com/cards/0?affiliate_id=combodeck"},{"SetName":"Vintage Masters","Rarity":"Rare","MultiverseId":383011,"PriceCentsPaper":0,"PriceCentsDigital":1,"AffiliateUrlPaper":null,"AffiliateUrlDigital":"https://www.cardhoarder.com/cards/52895?affiliate_id=combodeck"}],"BestPrintingIndex":0}]}'
    assert_equal nil, Market.parse_combodeck_json('Fog', json_str)
    assert_equal 169, Market.parse_combodeck_json('Masticore', json_str)
  end
end
