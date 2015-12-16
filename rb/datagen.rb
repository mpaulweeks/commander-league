
require_relative 'store'

USER_NAMES = ['Eliah', 'Qwerty', 'MPW', 'Dan', 'EDW']

def create_users()
  def make_slug(name)
    return name.downcase
  end

  def make_object(name)
    return {'slug' => make_slug(name), 'name' => name}
  end

  user_hash = Hash[USER_NAMES.map{|n| [make_slug(n), make_object(n)]}]
  db_hash = {KEY_USER => user_hash}
  save_database(db_hash)
end

create_users()
