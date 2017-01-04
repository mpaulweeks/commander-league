
require_relative 'store'

require 'json'
require 'net/http'
require 'nokogiri'
require 'open-uri'

COMBODECK_URL = "http://combodeck.net/Search/Inspector/CardInfo?CardName=%s"
MTG_PRICE_URL = "http://www.mtgprice.com/sets/%s/%s"

class MarketException < Exception
end

class MarketParseException < MarketException
end

class CombodeckException < MarketException
end

class Market

  def self.fetch_url(raw_url)
    escaped = URI.escape(raw_url)
    url = URI.parse(escaped)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    return res.body
  end

  def self.parse_combodeck_json(card_name, card_dict)
    if !card_dict || card_dict['CardName'].sub('Æ', 'Ae') != card_name
      return nil
    end

    min_price = nil
    set_prices = card_dict['Prices']['TcgPlayer']['SetPrices']
    set_prices.each do |printing|
      printing_prices = [printing['Low'], printing['Average'], printing['High'], printing['FoilAverage']]
      printing_prices.each do |printing_price|
        unless printing_price.nil? || printing_price == 0
          if min_price.nil? || printing_price < min_price
            min_price = printing_price
          end
        end
      end
    end
    return min_price
  end

  def self.is_split?(card_name)
    return card_name.include? '/'
  end

  def self.get_price(card_name)
    card_dict = nil
    combodeck_name = card_name
    if self.is_split? card_name
      return 0  # unfortunate hack
    end

    puts "Looking up %s price via Combodeck" % combodeck_name
    url = COMBODECK_URL % combodeck_name
    combodeck_response = self.fetch_url(url)
    if combodeck_response.nil? || combodeck_response.empty?
      raise CombodeckException
    end
    card_dict = JSON.parse(combodeck_response)
    price = self.parse_combodeck_json(combodeck_name, card_dict)
    if price.nil?
      raise MarketParseException
    end

    return price
  end
end
