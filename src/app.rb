require "debug"
class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do
        @people = db.execute('SELECT firstname, lastname, id FROM users')
        p @people[0]['firstname']
        erb :index
    end

    get '/register' do
        erb :register
    end

    get '/login' do
        erb :login
    end

    get '/registeracc'
        erb :regacc
    end
    get '/profile/:username' do |username|
         @username = username
         p @username

        @ordered_catch = db.execute('SELECT * FROM catch 
        INNER JOIN fish
        ON catch.fishid = fish.id
        WHERE userid = 1
        ORDER BY weight DESC')
        @catches = @ordered_catch.group_by {|x| x["type"]}
        @catch_key = @catches.keys  
        p @catch_key        


        #  @id = db.execute('SELECT id FROM users WHERE username LIKE ?', username).first['id']
    
        #  @orderedfish = db.execute('SELECT * FROM catch ORDER BY weight DESC')
        
       
       
       
       
       
        # # @topfish = db.execute('WITH RankedFish AS (
        # #     SELECT *,
        # #         ROW_NUMBER() OVER (PARTITION BY fishid ORDER BY weight DESC) AS row_num
        # #     FROM catch
        # #     WHERE userid = ?
        # #     )
        # #     SELECT * FROM RankedFish WHERE row_num = 1;', @id
        # # )
        
        
        
        
        p "wut"
        "wat"
        erb :profile
    end

    post '/register' do
        @loggedin = 1
        userid = @loggedin
        
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

    
end