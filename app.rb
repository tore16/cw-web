require 'sinatra'
require 'sinatra/reloader'
require 'csv'
require 'sqlite3'
require 'bcrypt'

require_relative 'model.rb'

enable :sessions

def test_login()
  if session[:user] == nil
    redirect '/login'
  end
end

after do
  p session[:user]
  p session[:user_id]
end

before ('/private/*') do
  test_login()
end

def test_admin()
 if session[:user] != nil && !session[:admin]
   redirect '/'
 end
end

before('/admin/*') do
  test_admin()
end

before('/admin/comments/:id/*') do
  test_admin() 
end

before('/admin/tasks/:task/*') do
  test_admin()
end

before('/admin/users/:user/*') do
  test_admin()
end

get('/') do
  erb(:index)
end

get('/login') do
  erb(:login)
end

get('/register') do
  erb(:register)
end

post('/login') do
  username = params[:username]
  password = params[:password]
  result = get_user_by_name(username)

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
      "FEL LOSEN"
    end
  else
    "Fel Användarnamn"
  end
end

get ('/home') do
  erb(:home)
end

post('/users/new') do 
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if (password == password_confirm)
    new_user(username, password)
    redirect('/')
  else
    #fel
    "lösenorden matchade inte"
  end

end

get('/users') do
  result = get_users()
  erb(:"users/index",locals:{users:result})
end

get('/users/:user') do
  id = params[:user]
  result = get_user_by_id(id)
  erb(:"users/show",locals:{user:result})
end

get('/admin/users/:user/edit') do
  id = params[:user]
  result = get_user_by_id(id)
  erb(:"users/edit",locals:{user:result})
end 

post ('/admin/users/:user/update') do
  id = params[:user].to_i
  admin = 0
  if params[:admin] = 1
    admin = 1
  end
  new_name = params[:name]
  update_user(id, new_name, admin)
  redirect('/users')
end

post ('/admin/users/:user/delete') do
  id = params[:user].to_i
  delete_user(id)
  redirect('/users')
end

get ('/tasks') do
  result = get_tasks()
  erb(:"tasks/index",locals:{tasks:result})
end

get ('/admin/tasks/new') do
  erb(:"tasks/new")
end

get('/tasks/:task') do
  id = params[:task]
  result = get_task_by_id(id)
  result1 = has_completed(id)
  result2 = get_comments_by_task(id)
  erb(:"tasks/show",locals:{task:result,users:result1,comments:result2})
end

get('/admin/tasks/:task/edit') do
  id = params[:task]
  result = get_task_by_id(id)
  erb(:"tasks/edit",locals:{task:result})
end 

post ('/admin/tasks/:task/update') do
  id = params[:task].to_i
  name = params[:name]
  type = params[:type]
  speed = params[:speed]
  content = params[:content]

  update_task(id, name, type, speed, content)
  redirect('/tasks')
end

post ('/admin/tasks/:task/delete') do
  id = params[:task].to_i
  delete_task(id)
  redirect('/tasks')
end

post ('/admin/tasks/new') do
  name = params[:name]
  type = params[:type]
  speed = params[:speed]
  content = params[:content]

  new_task(name, type, speed, content)
  redirect('/tasks')
end

post ('/private/tasks/complete') do
  userid = session[:user_id]
  taskid = params[:taskid]
  complete_task(userid, taskid)
  redirect("/tasks/#{taskid}")
end

post ('/private/comments/add') do
  taskid = params[:taskid]
  userid = session[:user_id]
  text = params[:content]
  add_comment(taskid, userid, text)
  redirect("/tasks/#{taskid}")
end

post ('/admin/comments/delete') do
  commentid = params[:id]
  comment = get_comment_by_id(commentid)
  delete_comment(commentid)
  redirect("/tasks/#{comment['taskid']}")
end

get ('/admin/comments/:id/edit') do
  id = params[:id]
  erb(:"comments/edit",locals:{id:id})
end

post ('/admin/comments/:id/update') do
  commentid = params[:id]
  comment = get_comment_by_id(commentid)
  text = params[:content]
  update_comment(commentid, text)
  redirect("/tasks/#{comment['taskid']}")
end
