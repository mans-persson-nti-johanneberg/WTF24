require "debug"
class App < Sinatra::Base

    enable :sessions


    helpers do
        def h(text)
            Rack::Utils.escape_html(text)
        end
    end

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do

        p session[:userid]
        @people = db.execute('SELECT username, id FROM users')
        p @people[0]['username']
        erb :index
    end

    get '/register' do
        if session[:userid]
            erb :register
        else
            redirect '/'
        end
    end

    get '/login' do
        erb :login
    end

    get '/regacc' do
        erb :regacc
    end
    get '/profile/:username' do |username|
         
        @profileid = db.execute('SELECT id FROM users WHERE username = ?', username).first['id']
        p "PROFILEID"
        p @profileid
        @username = username
        @ordered_catch = db.execute('SELECT * FROM catch 
        INNER JOIN fish
        ON catch.fishid = fish.id
        WHERE userid = ?
        ORDER BY weight DESC', @profileid)
        p @ordered_catch
        @catches = @ordered_catch.group_by {|x| x["type"]}
        p @catches
        @catch_key = @catches.keys  
        p @catch_key
        @comments = db.execute('SELECT * FROM comments WHERE commentedid = ?', @profileid)
        erb :profile
    end

    get '/login' do


        erb :login
    end

   

    post '/delete/:id' do |id|
        db.execute('DELETE FROM users WHERE id = ?', id)
        db.execute('DELETE FROM comments WHERE commenterid = ?', id)
        db.execute('DELETE FROM catch WHERE userid = ?', id)
        redirect '/'
    end

    post '/editacc/:id' do |id|
        p id
        p params
        newname = params['userlogin']
        db.execute('UPDATE users SET username = ? WHERE id = ?', newname, id)
        redirect '/'
    end

    post '/comment' do 
        p "userid:"
        p session[:userid]
        if session[:userid] != nil
          
            @commenterid = session[:userid]
            comment = params['comment']
            @commentedid = params['commentedid']
            commenter = db.execute('SELECT username FROM users WHERE id = ?', @commenterid).first['username']
            comment_time = Time.now
            time_string = "#{comment_time.year}-#{comment_time.month}-#{comment_time.day}"
            p  @commenterid, comment, time_string, commenter, @commentedid
            
            query = 'INSERT INTO comments 
            (commenterid, comment, time_string, commenter, commentedid)
            VALUES (?, ?, ?, ?, ?) RETURNING id'
            result = db.execute(query, @commenterid, comment, time_string, commenter, @commentedid).first
            

        end
        redirect '/'
        

    end


    post '/regacc' do 
        username = params['username']
        cleartext_password = params['password'] 
        password_check = params['password2']
        role = "user"

        if cleartext_password != password_check
            redirect '/regacc'
        end
        hashed_password = BCrypt::Password.create(cleartext_password)
        
        query = 'INSERT INTO users(username, hashed_password, role) VALUES (?,?,?) RETURNING id'
        result = db.execute(query, username, hashed_password, role).first
        session[:userid] = result['id']
        session[:role] = result['role']
        redirect '/'


    end

    post '/login' do

        username = params['userlogin']
        clear_passw = params['passwordlogin']

        user = db.execute('SELECT * FROM users WHERE username = ?', username).first
        

        password_from_db = BCrypt::Password.new(user['hashed_password'])

        if password_from_db == clear_passw
            session[:userid] = user['id'] 
            session[:role] = user['role']
        else 
            redirect '/login'
        end
        
        redirect'/'



    end
    

    post '/register' do
        userid = session[:userid]
        
        type = params['type']
        weight = params['weight']
        location = params['location']
        time = params['time']
        fishid = db.execute('SELECT id FROM fish WHERE type = ?', type ).first['id']
        p userid, weight, location, time, fishid
        query = 'INSERT INTO catch (userid, weight, location, time, fishid) VALUES (?, ?, ?, ?, ?) RETURNING id'
        result = db.execute(query, userid, weight, location, time, fishid).first
        redirect '/'

    end

    post '/logout' do
        session.destroy
        redirect'/'

    end

    
end