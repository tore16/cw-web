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

def get_usernames()
  db = SQLite3::Database.new('db/database.db')
  db.execute("SELECT username FROM users")
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

def update_user(userid, new_name, is_admin)
  db = SQLite3::Database.new('db/database.db')
  db.execute("UPDATE users SET username=?,authorisation_level=? Where Id = ?", new_name, is_admin, userid)
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
  db.execute("Select * FROM users INNER JOIN comments ON comments.userid = users.id WHERE taskid = ?", taskid)
end

def delete_comment(commentid)
  db = SQLite3::Database.new('db/database.db')
  db.execute("DELETE FROM comments WHERE Id = ?", commentid)
end

def update_comment(commentid, content)
  db = SQLite3::Database.new('db/database.db')
  db.execute("UPDATE comments SET text=? WHERE Id = ?", content, commentid)
end

def get_comment_by_id (commentid)
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  db.execute("SELECT * FROM comments WHERE Id = ?", commentid).first
end

def get_user_permission_level (userid)
  db = SQLite3::Database.new('db/database.db')
  db.execute("SELECT permission_level FROM users INNER JOIN roles ON users.roleid = roles.id WHERE Id = ?", userid).first
end

def move_comments (userid)
  db = SQLite3::Database.new('db/database.db')
  db.execute("UPDATE comments SET userid=1 WHERE userid=?", userid)
end

def remove_completed (userid)
  db = SQLite3::Database.new('db/database.db')
  db.execute("DELETE FROM user_task_rel WHERE userid=?", userid)
end

def remove_task_comments (taskid)
  db = SQLite3::Database.new('db/database.db')
  db.execute("DELETE FROM comments WHERE taskid=?", taskid)
end


# Validering

def validate_password(password, password_confirm)

  if password != password_confirm
    return "Lösenorden machar inte"
  end

  if password.length() < 8
    return "lösenord måste vara 8 eller längre"
  end

  uppercase = /[A-Z]/
  lowercase = /[a-z]/
  digit = /[0-9]/

  if uppercase.match(password) == nil
    return "Måste ha minst en stor bokstav"
  end

  if lowercase.match(password) == nil
    return "Måste ha minst en liten bokstav"
  end

  if digit.match(password) == nil
    return "Måste ha minst en siffra"
  end

  ""
end

def validate_name(username)
  users = get_usernames()
  if username.length <= 0
    return "Användarnamn för kort"
  end

  if users.include? username
    return "Användare finns redan"
  end

  ""
end

