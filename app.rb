require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'csv'
require 'sqlite3'
require 'bcrypt'

require_relative "models.rb"

enable :sessions

get('/') do
  if session[:user] == nil
    slim(:index)
  else
    slim(:home)
  end
end

get('/login') do
  slim(:login)
end

get('/register') do
  slim(:register)
end

post('/login') do
  username = params[:username]
  password = params[:password]
  result = get_user_by_name(username)
  pwdigest = result["pwdigest"]
  id = result["id"]

  if BCrypt::Password.new(pwdigest) == password
    session[:user] = username
    session[:user_id] = id
    redirect('/')
  else
    "FEL LOSEN"
  end
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
    "losenorden matchade inte"
  end
end

get('/users') do
  result = get_users()
  erb(:"users/index",locals:{users:result})
end

get('/users/:user') do
  user = params[:user]
  result = get_user_by_id(user)
  erb(:"users/show",locals:{user:result})
end
