
require 'json'
require_relative '../file_path'

def generate_multiverse_ids()
  all_sets_file = File.read(FilePath.all_sets)
  all_sets_hash = JSON.parse(all_sets_file)

  multiverse_hash = {}
  all_sets_hash.each do |key, sets|
    sets['cards'].each do |card|
      name = card["name"]
      mid = card["multiverseid"]
      if mid
        if card['layout'] == 'split'
          if name != card['names'][0]
            next
          end
          name = card['names'].join('/')
        end
        multiverse_hash[name] = mid
      end
    end
  end

  File.open(FilePath.multiverse_ids, "w") do |f|
    f.write(multiverse_hash.to_json)
  end
end

if __FILE__ == $PROGRAM_NAME
  generate_multiverse_ids()
end
