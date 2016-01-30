
require_relative 'store'

require 'json'
require 'net/http'

COMBODECK_URL = "http://combodeck.net/Search/FullCard?cardName=%s"

class MarketException < Exception
end

class MarketParseException < MarketException
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

  def self.parse_combodeck_json(card_name, json_str)
    json_dict = JSON.parse json_str
    min_price = nil
    json_dict['Cards'].each do |card|
      if card['CardName'] == card_name
        card['Printings'].each do |printing|
          printing_price = printing['PriceCentsPaper']
          if printing_price && printing_price > 0
            if min_price.nil? || printing_price < min_price
              min_price = printing_price
            end
          end
        end
      end
    return 0
  end

  def self.fetch_mtg_price(card_name, combodeck_json)
    json_dict = JSON.parse combodeck_json
    json_dict['Cards'].each do |card|
      if card['CardName'] == card_name
        # TBD
      end
    end
    return 0
    end
    return min_price
  end

  def self.get_price(card_name)
    url = COMBODECK_URL % card_name
    json_str = self.fetch_url(url)
    price = self.parse_combodeck_json(card_name, json_str)
    if price.nil?
      price = self.fetch_mtg_price(card_name, json_str)
      raise MarketParseException
    end
    return price
  end
end
