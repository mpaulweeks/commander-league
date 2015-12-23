
require 'json'
require 'net/http'

COMBODECK_URL = "http://combodeck.net/Search/FullCard?cardName=%s"


module Market

  def self.fetch_url(raw_url)
    escaped = URI.escape(raw_url)
    url = URI.parse(escaped)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    return res.body
  end

  def self.parse_json(card_name, json_str)
    json_dict = JSON.parse json_str
    json_dict['Cards'].each do |card|
      if card['CardName'] == card_name
        return card['PriceInCents'] / 100.0
      end
    end
  end

  def Market.get_price(card_name)
    return 0.25
    # url = COMBODECK_URL % card_name
    # json_str = self.fetch_url(url)
    # price = self.parse_json(card_name, json_str)
    # return price
  end
end
