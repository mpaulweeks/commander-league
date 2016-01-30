
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

  def self.parse_combodeck_json(card_name, json_dict)
    min_price = nil
    json_dict['Cards'].each do |card|
      if card['CardName'] == card_name
        card['Printings'].each do |printing|
          printing_price = printing['PriceCentsPaper']
          unless printing_price.nil? || printing_price == 0
            if min_price.nil? || printing_price < min_price
              min_price = printing_price
            end
          end
        end
      end
    end
    return min_price
  end

  def self.fetch_mtg_price(card_name, json_dict)
    json_dict['Cards'].each do |card|
      if card['CardName'] == card_name
        # TBD
      end
    end
    return nil
  end

  def self.get_price(card_name)
    url = COMBODECK_URL % card_name
    combodeck_json_dict = JSON.parse self.fetch_url(url)
    price = self.parse_combodeck_json(card_name, combodeck_json_dict)
    if price.nil?
      price = self.fetch_mtg_price(card_name, combodeck_json_dict)
      if price.nil?
        raise MarketParseException
      end
    end
    return price
  end
end
