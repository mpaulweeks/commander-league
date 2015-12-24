
require 'json'

def generate_multiverse_ids()
  all_sets_file = File.read('json/AllSets.json')
  all_sets_hash = JSON.parse(all_sets_file)

  multiverse_hash = {}
  all_sets_hash.each do |key, sets|
    sets['cards'].each do |card|
      name = card["name"]
      mid = card["multiverseid"]
      if mid
        multiverse_hash[name] = mid
      end
    end
  end

  File.open('json/multiverse_ids.json', "w") do |f|
    f.write(multiverse_hash.to_json)
  end
end

generate_multiverse_ids()
