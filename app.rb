require 'sinatra'
require 'sinatra/reloader'
require 'csv'
require 'sqlite3'
require 'bcrypt'

require_relative 'model.rb'

enable :sessions

attempts = {}

def test_owner(owner)
  session[:user_id] == owner.to_i
end

def test_login()
  if session[:user] == nil
    redirect '/login'
  end
end

before ('/private/*') do
  test_login()
end

def test_admin()
 if session[:admin]
   return true
 end
 false
end

before('/admin/*') do
  unless test_admin()
    redirect '/'
  end
end

def get_user_from_comment(id)
  comment = get_comment_by_id(id)
  get_user_by_id(comment['userid'])
end

before('/owner/comments/:id/*') do
  commentid = params[:id]
  owner = get_user_from_comment(id)
  unless test_admin() || test_owner(owner)
    redirect '/'
  end
end

before('/admin/tasks/:task/*') do
  unless test_admin()
    redirect '/'
  end
end

before('/owner/users/:user/*') do
  owner = params[:user]
  unless test_admin() || test_owner(owner)
    redirect '/'
  end
end

# laddar hemskärmen
#
get('/') do
  erb(:index)
end

# laddar loginsidan
#
get('/login') do
  erb(:login)
end

# laddar registreringssidan
#
get('/register') do
  erb(:register)
end

# loggar in som användare om användare finns och lösenord stämmer
#
# @params: username, password
post('/login') do
  ip = request.ip

  if attempts[ip] == nil
    attempts[ip] = 0
  end

  username = params[:username]
  password = params[:password]
  result = get_user_by_name(username)

  if (Time.now - attempts[ip]).to_i >= 5
    if result != nil
      pwdigest = result["pwdigest"]
      id = result["id"]
      if BCrypt::Password.new(pwdigest) == password
        session[:user] = username
        session[:user_id] = id
        if result['authorisation_level'] >= 1
          session[:admin] = true
        else
          session[:admin] = false
        end
        redirect('/')
      else
        attempts[ip] = Time.now
        "FEL LOSEN"
      end
    else
      attempts[ip] = Time.now
      "Fel Användarnamn"
    end
  else
    attempts[id] = Time.now
    "vänta lite"
  end
end

# skapar en ny användare om användaren inte redan finns, lösenorden stämmer överens och lösenordet är komplext nog
#
# @params: username, password, password_confirm
post('/users/new') do 
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  username_error = validate_name(username)
  password_error = validate_password(password, password_confirm)

  if username_error == ""
    if password_error == ""
      new_user(username, password)
      redirect('/')
    else
      password_error
    end

  else
    username_error
  end

end

# visar en lista på varje användare
#
get('/users') do
  result = get_users()
  erb(:"users/index",locals:{users:result})
end

# visar info om specifik användare
#
get('/users/:user') do
  id = params[:user]
  result = get_user_by_id(id)
  erb(:"users/show",locals:{user:result})
end

# visar form för att redigera en användare om användaren har behörighet
#
get('/owner/users/:user/edit') do
  id = params[:user]
  result = get_user_by_id(id)
  erb(:"users/edit",locals:{user:result})
end 

# ändrar värden för användare om användaren har behörighet
#
# @params: name, admin
#
post ('/owner/users/:user/update') do
  id = params[:user].to_i
  p params[:admin]
  admin = 0
  if params[:admin].to_i == 1 && session[:admin]
    admin = 1
  end
  new_name = params[:name]
  update_user(id, new_name, admin)
  redirect('/users')
end

# raderar användare och ändrar ägare av dess kommentarer om användare har behörighet
#
# @params: 
# 
post ('/owner/users/:user/delete') do
  id = params[:user].to_i
  move_comments(id)
  remove_completed(id)
  delete_user(id)
  redirect('/users')
end

# visar lista på alla uppgifter
#
get ('/tasks') do
  result = get_tasks()
  erb(:"tasks/index",locals:{tasks:result})
end

# visar form för att skapa ny uppgift om användare har behörighet
#
get ('/admin/tasks/new') do
  erb(:"tasks/new")
end

# visar info om och kommentarer av en viss uppgift
get('/tasks/:task') do
  id = params[:task]
  result = get_task_by_id(id)
  result1 = has_completed(id)
  result2 = get_comments_by_task(id)
  erb(:"tasks/show",locals:{task:result,users:result1,comments:result2})
end

# visar form för att redigera en uppgift om användare har behörighett
#
get('/admin/tasks/:task/edit') do
  id = params[:task]
  result = get_task_by_id(id)
  erb(:"tasks/edit",locals:{task:result})
end 

# redigerar en uppgift om användare har behörighet
#
# @params: name, type, speed, content
#
post ('/admin/tasks/:task/update') do
  id = params[:task].to_i
  name = params[:name]
  type = params[:type]
  speed = params[:speed]
  content = params[:content]

  update_task(id, name, type, speed, content)
  redirect('/tasks')
end

# tar bort uppgift om anvädare har behörighet
#
# @params:
#
post ('/admin/tasks/:task/delete') do
  id = params[:task].to_i
  remove_task_comments(id)
  delete_task(id)
  redirect('/tasks')
end

# skapar ny uppgift om användare har behörighet
#
# @params: name, type, speed, content
post ('/admin/tasks/new') do
  name = params[:name]
  type = params[:type]
  speed = params[:speed]
  content = params[:content]

  new_task(name, type, speed, content)
  redirect('/tasks')
end

# registrerar att användare gjort en uppgift om användare är inloggad
#
# @params: taskid
post ('/private/tasks/complete') do
  userid = session[:user_id]
  taskid = params[:taskid]
  complete_task(userid, taskid)
  redirect("/tasks/#{taskid}")
end

# lägger till en kommentar till uppgift om användare är inloggad
#
# @params: taskid, content
#
post ('/private/comments/add') do
  taskid = params[:taskid]
  userid = session[:user_id]
  text = params[:content]
  add_comment(taskid, userid, text)
  redirect("/tasks/#{taskid}")
end

# tar bort en kommentar om användare har behörighet
#
# @params:
post ('/owner/comments/:id/delete') do
  commentid = params[:id]
  comment = get_comment_by_id(commentid)
  delete_comment(commentid)
  redirect("/tasks/#{comment['taskid']}")
end

# visar form för att redigera kommentar om användare har behörighet
get ('/owner/comments/:id/edit') do
  id = params[:id]
  erb(:"comments/edit",locals:{id:id})
end

# redigerar kommentar om användare har behörighet
#
# @params: content
post ('/owner/comments/:id/update') do
  commentid = params[:id]
  comment = get_comment_by_id(commentid)
  text = params[:content]
  update_comment(commentid, text)
  redirect("/tasks/#{comment['taskid']}")
end
