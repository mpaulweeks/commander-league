
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

class CombodeckException < MarketException
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
  'Magic 2014 Core Set' => 'M14',
  'Magic 2015 Core Set' => 'M15',
  'Magic: The Gathering-Commander' => 'Commander',
  'Commander 2013 Edition' => 'Commander 2013',
  'Planechase 2012 Edition' => 'Planechase 2012',
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

  def self.parse_combodeck_json(card_name, card_dict)
    if card_dict['CardName'] != card_name
      return nil
    end

    min_price = nil
    card_dict['Printings'].each do |printing|
      printing_price = printing['PriceCentsPaper']
      unless printing_price.nil? || printing_price == 0
        if min_price.nil? || printing_price < min_price
          min_price = printing_price
        end
      end
    end
    return min_price
  end

  def self.parse_mtg_price(url, card_name)
    url = url.gsub(' ', '_')
    url = url.gsub("'", '')
    escaped = URI.escape(url)
    page = Nokogiri::HTML(open(escaped))
    raw_text = page.css('#card-name').text
    unless raw_text.include? card_name.gsub('__', ' // ')
      return nil
    end
    raw_text.split('&nbsp').each do |chunk|
      if chunk.include? '$'
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

  def self.fetch_mtg_price(card_name, card_dict)
    formatted_name = card_name
    formatted_name = formatted_name.gsub('/', '__')
    if card_name.include? 'Æ'
      formatted_names = [
        formatted_name.gsub('Æ', 'AE'),
        formatted_name.gsub('Æ', 'Ae'),
      ]
    else
      formatted_names = [formatted_name]
    end
    min_price = nil
    formatted_names.each do |mtg_price_name|
      card_dict['Printings'].each do |printing|
        set_name = printing['SetName']
        if SetRename.has_key? set_name
          set_name = SetRename[set_name]
        end
        url = MTG_PRICE_URL % [set_name, mtg_price_name]
        printing_price = self.parse_mtg_price(url, mtg_price_name)
        puts "%s - %s" % [url, printing_price]
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
      combodeck_name = card_name.split('/')[0]
    end

    puts "Looking up %s price via Combodeck" % combodeck_name
    url = COMBODECK_URL % combodeck_name
    combodeck_json_dict = JSON.parse self.fetch_url(url)
    combodeck_json_dict['Cards'].each do |card|
      if card['CardName'] == combodeck_name
        card_dict = card
      end
    end
    if card_dict.nil?
      raise CombodeckException
    end
    price = self.parse_combodeck_json(combodeck_name, card_dict)

    if price.nil?
      puts "Looking up via MTGPrice"
      price = self.fetch_mtg_price(card_name, card_dict)
      if price.nil?
        raise MarketParseException
      end
    end
    return price
  end
end
