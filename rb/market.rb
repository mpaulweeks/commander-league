
require_relative 'store'

require 'json'
require 'net/http'
require 'nokogiri'
require 'open-uri'

COMBODECK_URL = "http://combodeck.net/Search/FullCard?cardName=%s"
MTG_PRICE_URL = "http://www.mtgprice.com/sets/%s/%s"

class MarketException < Exception
end

class MarketParseException < MarketException
end

SetRename = {
  'Classic Sixth Edition' => '6th Edition',
  'Seventh Edition' => '7th Edition',
  'Eight Edition' => '8th Edition',
  'Ninth Edition' => '9th Edition',
  'Tenth Edition' => '10th Edition',
  'Magic 2010' => 'M10',
  'Magic 2011' => 'M11',
  'Magic 2012' => 'M12',
  'Magic 2013' => 'M13',
  'Magic 2014' => 'M14',
  'Magic 2015' => 'M15',
}

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

  def self.parse_mtg_price(url, card_name)
    url = url.gsub(' ', '_')
    escaped = URI.escape(url)
    puts escaped
    page = Nokogiri::HTML(open(escaped))
    raw_text = page.css('#card-name').text
    unless raw_text.include? card_name
      return nil
    end
    raw_text.split('&nbsp').each do |chunk|
      if chunk.include? '$'
        puts chunk
        dollar, change = chunk[1..-1].split('.')
        price = change.to_i
        if dollar.length > 0
          price += dollar.to_i * 100
        end
        return price
      end
    end
    return nil
  end

  def self.fetch_mtg_price(card_name, json_dict)
    json_dict['Cards'].each do |card|
      if card['CardName'] == card_name
        formatted_name = card_name.gsub('Æ', 'AE')
        # other_name = card['OtherSideCardName']
        # if other_name
        #   if card['Side'] == 1
        #     formatted_name = "%s__%s" % [other_name, card_name]
        #   else
        #     formatted_name = "%s__%s" % [card_name, other_name]
        #   end
        # end
        min_price = nil
        card['Printings'].each do |printing|
          set_name = printing['SetName']
          if SetRename.has_key? set_name
            set_name = SetRename[set_name]
          end
          url = MTG_PRICE_URL % [set_name, formatted_name]
          printing_price = self.parse_mtg_price(url, formatted_name)
          unless printing_price.nil? || printing_price == 0
            if min_price.nil? || printing_price < min_price
              min_price = printing_price
            end
          end
        end
        return min_price
      end
    end
    return nil
  end

  def self.get_price(card_name)
    puts "fetching price for: %s" % card_name
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
