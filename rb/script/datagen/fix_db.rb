
require_relative '../../store'

if __FILE__ == $PROGRAM_NAME
  db_cache = Store.load_database
  Store.glass_database!
  Store.update_database!(db_cache)
end
