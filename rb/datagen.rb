
require_relative 'store'

USER_NAMES = [
  ['eliah', 'Eliah'],
  ['qwerty', 'Patrick'],
  ['mpw', 'M. Paul'],
  ['gant', 'Dan'],
  ['edmond', 'Edmond'],
]

def create_users()
  def make_object(tuple)
    return {'slug' => tuple[0], 'name' => tuple[1]}
  end

  user_hash = Hash[USER_NAMES.map{|n| [n[0], make_object(n)]}]
  db_hash = {Store::KEY_USER => user_hash}
  Store.update_database(db_hash)
end

create_users()

puts Store.load_database()