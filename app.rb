require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'csv'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
  if session[:user] = nil
  slim(:index)
end

get('/login') do
  slim(:login)
end

get('/register') do
  slim(:register)
end

def get_user(username)
  db = SQLite3::Database.new('db/database.db')
  db.results_as_hash = true
  return db.execute("SELECT * FROM users WHERE username = ?", username).first
end

post('/login') do
  username = params[:username]
  password = params[:password]
  result = get_user(username)
  pwdigest = result["pwdigest"]
  id = result["id"]

  if BCrypt::Password.new(pwdigest) == password
    session[:user] = username
    redirect('/todos')
  else
    "FEL LOSEN"
  end
end

def new_user(username, password) 
  password_digest = BCrypt::Password.create(password)
  db = SQLite3::Database.new('db/database.db')
  db.execute("INSERT INTO users (username,pwdigest) VALUES (?, ?)", username, password_digest)
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

get('/users/:user/profile') do
  slim(:"users/profile")
end

post('/calculate') do
  val1 = params[:value1].to_f
  operator = params[:operator]
  val2 = params[:value2].to_f

  result = case operator
  when "+"
    "#{val1} + #{val2} = #{val1 + val2}"
  when "-"
    "#{val1} - #{val2} = #{val1 - val2}"
  when "/"
    "#{val1} / #{val2} = #{val1 / val2}"
  when "*"
    "#{val1} * #{val2} = #{val1 * val2}"
  else
    "FEL"
  end

  puts("result: #{result}")
  session[:results] << result
  redirect('/calculator')
end

get("/data") do
  @data = CSV.open("data/MOCK_DATA.csv", headers: :first_row).map(&:to_h)
  slim(:data)
end
