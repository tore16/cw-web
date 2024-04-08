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
  db.execute("SELECT * FROM users WHERE username = ?", username).first
end

def get_user_by_id(userid)
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  db.execute("SELECT * FROM users WHERE id = ?", userid).first
end

def update_user(userid, new_name)
  db = SQLite3::Database.new('db/database.db')
  db.execute("UPDATE users SET username=? Where Id = ?", new_name, userid)
end

def delete_user(userid)
  db = SQLite3::Database.new('db/database.db')
  db.execute("DELETE FROM users WHERE Id = ?", userid)
end

def get_tasks()
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  db.execute("SELECT * FROM tasks")
end

def get_task_by_name(taskname)
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  db.execute("SELECT * FROM tasks WHERE taskname = ?", username).first
end

def get_task_by_id(taskid)
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  db.execute("SELECT * FROM tasks WHERE id = ?", taskid).first
end

def update_task(taskid, name, type, speed, content)
  db = SQLite3::Database.new('db/database.db')
  db.execute("UPDATE tasks SET name=?,type=?, baud=?, content=? WHERE Id = ?", name, type, speed, content, taskid)
end

def delete_task(taskid)
  db = SQLite3::Database.new('db/database.db')
  db.execute("DELETE FROM tasks WHERE Id = ?", taskid)
end

def new_task(name, type, speed, content) 
  db = SQLite3::Database.new('db/database.db')
  db.execute("INSERT INTO tasks (name,type,baud,content) VALUES (?, ?, ?, ?)", name, type, speed, content)
end

def complete_task(userid, taskid)
  db = SQLite3::Database.new('db/database.db')
  db.execute("INSERT INTO user_task_rel (userid,taskid) VALUES (?, ?)", userid, taskid)
end

def has_completed(taskid)
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  db.execute("SELECT users.username FROM user_task_rel INNER JOIN users ON user_task_rel.userid = users.id WHERE taskid = ?", taskid)
end

def add_comment(taskid, userid, text)
  time = Time.now.to_i
  db = SQLite3::Database.new('db/database.db')
  db.execute("INSERT INTO comments (userid,taskid,time,text) VALUES (?, ?, ?, ?)", userid, taskid, time, text)
end

def get_comments_by_user(userid)
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  db.execute("Select * FROM comments WHERE userid = ?", userid)
end

def get_comments_by_task(taskid)
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  db.execute("Select * FROM comments INNER JOIN users ON comments.userid = users.id WHERE taskid = ?", taskid)
end
