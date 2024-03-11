def new_user(username, password) 
  password_digest = BCrypt::Password.create(password)
  db = SQLite3::Database.new('db/database.db')
  db.execute("INSERT INTO users (username,pwdigest) VALUES (?, ?)", username, password_digest)
end

def get_users()
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  db.execute("SELECT * FROM users")
end

def get_user_by_name(username)
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  return db.execute("SELECT * FROM users WHERE username = ?", username).first
end

def get_user_by_id(userid)
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  return db.execute("SELECT * FROM users WHERE id = ?", userid).first
end

def update_user(userid, new_name)
  db = SQLite3::Database.new('db/database.db')
  db.execute("UPDATE users SET username=? Where Id = ?", new_name, userid)
end

def delete_user(userid)
  db = SQLite3::Database.new('db/database.db')
  db.execute("DELETE FROM users WHERE Id = ?", userid)
end
