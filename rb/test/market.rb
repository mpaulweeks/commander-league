
require "minitest/autorun"
require_relative '../market'

require 'json'

class MarketTest < Minitest::Test

  def test_get_price_simple
    refute_equal 0, Market.get_price('Masticore')
  end

  def test_get_price_space
    refute_equal 0, Market.get_price('Doom Blade')
  end

  def test_get_price_unicode
    refute_equal 0, Market.get_price('Aetherspouts')
  end

  def test_get_price_foil_only
    refute_equal 0, Market.get_price('Ikra Shidiqi, the Usurper')
  end

  def test_url_fetch
    card_name = 'Masticore'
    url = COMBODECK_URL % card_name
    json_str = Market.fetch_url(url)
    json_dict = JSON.parse(json_str)
    assert_equal json_dict['CardName'], card_name
  end

  def test_raises_on_fail
    assert_raises(CombodeckException) { Market.get_price 'fart' }
  end

  def test_combodeck_parse
    json_dict = JSON.parse '{"HasInspectorData":true,"CardName":"Masticore","CardUrl":"/Card/Masticore/Urza\u0027s_Destiny","OtherSideCard1Name":null,"OtherSideCard1Url":null,"OtherSideCard2Name":null,"OtherSideCard2Url":null,"Side":0,"ManaCost":"{4}","Type":"Artifact Creature — Masticore","Text":"At the beginning of your upkeep, sacrifice Masticore unless you discard a card.\u003c/p\u003e\u003cp\u003e{2}: Masticore deals 1 damage to target creature.\u003c/p\u003e\u003cp\u003e{2}: Regenerate Masticore.","PowerAndToughness":"4/4","Loyalty":null,"Color":"Colorless","Layout":"Normal","Prices":{"TcgPlayer":{"SetPrices":[{"Url":"http://store.tcgplayer.com/magic/urzas-destiny/masticore?partner=COMBODECK","SetName":"Urza\u0027s Destiny","MtgJsonSetCode":"UDS","Rarity":"Rare","Low":86,"Average":161,"High":499,"FoilAverage":1995},{"Url":"http://store.tcgplayer.com/magic/from-the-vault-relics/masticore?partner=COMBODECK","SetName":"From the Vault: Relics","MtgJsonSetCode":"V10","Rarity":"Mythic Rare","Low":0,"Average":0,"High":0,"FoilAverage":166}]},"Mkm":{"SetPrices":[{"Url":"https://magiccardmarket.eu/Products/Singles/Urza%27s+Destiny/Masticore","SetName":"Urza\u0027s Destiny","MtgJsonSetCode":"UDS","Rarity":"Rare","Low":20,"LowMint":35,"Average":266,"FoilLow":1795},{"Url":"https://magiccardmarket.eu/Products/Singles/From+the+Vault%3A+Relics/Masticore","SetName":"From the Vault: Relics","MtgJsonSetCode":"V10","Rarity":"Mythic Rare","Low":71,"LowMint":71,"Average":241,"FoilLow":0}]},"Cardhoarder":{"SetPrices":[{"Url":"https://www.cardhoarder.com/cards/12763?affiliate_id=combodeck","UrlFoil":"https://www.cardhoarder.com/cards/12764?affiliate_id=combodeck","SetName":"Urza\u0027s Destiny","MtgJsonSetCode":"UDS","Rarity":"Rare","Price":1,"PriceFoil":40,"Stock":4,"StockFoil":1},{"Url":"https://www.cardhoarder.com/cards/52895?affiliate_id=combodeck","UrlFoil":"https://www.cardhoarder.com/cards/52896?affiliate_id=combodeck","SetName":"Vintage Masters","MtgJsonSetCode":"VMA","Rarity":"Rare","Price":1,"PriceFoil":3,"Stock":4,"StockFoil":1},{"Url":"https://www.cardhoarder.com/cards/0?affiliate_id=combodeck","UrlFoil":"https://www.cardhoarder.com/cards/37634?affiliate_id=combodeck","SetName":"From the Vault: Relics","MtgJsonSetCode":"V10","Rarity":"Mythic Rare","Price":0,"PriceFoil":38,"Stock":0,"StockFoil":4}]}},"SetName":null,"Reserved":true,"Rulings":[],"Legalities":[{"Format":"Legacy","Status":"Legal"},{"Format":"Vintage","Status":"Legal"},{"Format":"Commander","Status":"Legal"},{"Format":"Standard","Status":"Not in format"},{"Format":"Modern","Status":"Not in format"},{"Format":"Pauper (MTGO)","Status":"Not in format"},{"Format":"Pauper (Paper)","Status":"Not in format"}],"Decks":[],"Mentions":[],"Recommendations":[{"CardName":"Cogwork Tracker","CardUrl":"/Card/Cogwork_Tracker","CardImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/conspiracy/cogwork-tracker-CDMV-382235.jpg"},{"CardName":"Lurking Jackals","CardUrl":"/Card/Lurking_Jackals","CardImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/urzas-destiny/lurking-jackals-CDMV-19116.jpg"},{"CardName":"Scandalmonger","CardUrl":"/Card/Scandalmonger","CardImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/mercadian-masques/scandalmonger-CDMV-19816.jpg"},{"CardName":"Raging Bull","CardUrl":"/Card/Raging_Bull","CardImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/legends/raging-bull-CDMV-1589.jpg"},{"CardName":"Rofellos","CardUrl":"/Card/Rofellos","CardImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/vanguard/rofellos-CDMV-12145.jpg"},{"CardName":"Jasmine Seer","CardUrl":"/Card/Jasmine_Seer","CardImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/urzas-destiny/jasmine-seer-CDMV-15124.jpg"},{"CardName":"Deepwood Elder","CardUrl":"/Card/Deepwood_Elder","CardImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/mercadian-masques/deepwood-elder-CDMV-22895.jpg"},{"CardName":"Crumbling Sanctuary","CardUrl":"/Card/Crumbling_Sanctuary","CardImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/mercadian-masques/crumbling-sanctuary-CDMV-19746.jpg"},{"CardName":"Slinking Skirge","CardUrl":"/Card/Slinking_Skirge","CardImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/urzas-destiny/slinking-skirge-CDMV-15786.jpg"},{"CardName":"Urborg Shambler","CardUrl":"/Card/Urborg_Shambler","CardImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/invasion/urborg-shambler-CDMV-23035.jpg"},{"CardName":"Stronghold Taskmaster","CardUrl":"/Card/Stronghold_Taskmaster","CardImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/stronghold/stronghold-taskmaster-CDMV-5249.jpg"},{"CardName":"Scragnoth","CardUrl":"/Card/Scragnoth","CardImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/tempest/scragnoth-CDMV-4787.jpg"}],"PrintingsById":{"CDMV-13087":{"FlavorText":null,"Artist":"Paolo Parente","Number":"134","ImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/urzas-destiny/masticore-CDMV-13087.jpg","ComboverseId":"CDMV-13087","PrintingUrl":"/Card/Masticore/Urza\u0027s_Destiny/CDMV-13087","Translations":[]},"CDMV-212629":{"FlavorText":null,"Artist":"Steven Belledin","Number":"7","ImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/from-the-vault-relics/masticore-CDMV-212629.jpg","ComboverseId":"CDMV-212629","PrintingUrl":"/Card/Masticore/From_the_Vault_Relics/CDMV-212629","Translations":[]},"CDMV-383011":{"FlavorText":null,"Artist":"Steven Belledin","Number":"275","ImageUrl":"//cdmvi.s3-website-us-east-1.amazonaws.com/{format}/vintage-masters/masticore-CDMV-383011.jpg","ComboverseId":"CDMV-383011","PrintingUrl":"/Card/Masticore/Vintage_Masters/CDMV-383011","Translations":[]}},"SetsByName":{"Urza\u0027s Destiny":{"CardInSetUrl":"/Card/Masticore/Urza\u0027s_Destiny","SetName":"Urza\u0027s Destiny","SetUrl":"/Set/Urza\u0027s_Destiny","MtgJsonSetCode":"UDS","Rarity":"Rare","PriceCentsDollars":161,"PriceCentsEuros":266,"PriceCentsTickets":1,"TcgPlayerUrl":"http://store.tcgplayer.com/magic/urzas-destiny/masticore?partner=COMBODECK","MkmUrl":"https://www.magiccardmarket.eu/Products/Singles/Urza%27s+Destiny/Masticore","MtgoId":12763,"MtgoFoilId":12764,"ReleaseDate":"June 7, 1999","PrintingIds":["CDMV-13087"],"PrintingUrls":["/Card/Masticore/Urza\u0027s_Destiny/CDMV-13087"]},"From the Vault: Relics":{"CardInSetUrl":"/Card/Masticore/From_the_Vault_Relics","SetName":"From the Vault: Relics","SetUrl":"/Set/From_the_Vault_Relics","MtgJsonSetCode":"V10","Rarity":"Mythic Rare","PriceCentsDollars":166,"PriceCentsEuros":241,"PriceCentsTickets":0,"TcgPlayerUrl":"http://store.tcgplayer.com/magic/from-the-vault-relics/masticore?partner=COMBODECK","MkmUrl":"https://www.magiccardmarket.eu/Products/Singles/From+the+Vault%3A+Relics/Masticore","MtgoId":0,"MtgoFoilId":37634,"ReleaseDate":"August 27, 2010","PrintingIds":["CDMV-212629"],"PrintingUrls":["/Card/Masticore/From_the_Vault_Relics/CDMV-212629"]},"Vintage Masters":{"CardInSetUrl":"/Card/Masticore/Vintage_Masters","SetName":"Vintage Masters","SetUrl":"/Set/Vintage_Masters","MtgJsonSetCode":"VMA","Rarity":"Rare","PriceCentsDollars":0,"PriceCentsEuros":0,"PriceCentsTickets":1,"TcgPlayerUrl":null,"MkmUrl":"https://www.magiccardmarket.eu","MtgoId":52895,"MtgoFoilId":52896,"ReleaseDate":"June 16, 2014","PrintingIds":["CDMV-383011"],"PrintingUrls":["/Card/Masticore/Vintage_Masters/CDMV-383011"]}},"OrderedSetNames":["Urza\u0027s Destiny","From the Vault: Relics","Vintage Masters"]}'
    assert_equal nil, Market.parse_combodeck_json('Fog', json_dict)
    assert_equal 86, Market.parse_combodeck_json('Masticore', json_dict)
  end

end
