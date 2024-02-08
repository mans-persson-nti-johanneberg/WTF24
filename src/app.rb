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

    post '/register' do
        @loggedin = 1
        userid = @loggedin
        
        type = params['type']
        weight = params['weight']
        location = params['location']
        time = params['time']
        fishid = db.execute('SELECT id FROM fish WHERE type = ?', type )['id'].first
        query = 'INSERT INTO catch (userid, weight, location, time, fishid) VALUES (?, ?, ?, ?, ?) RETURNING id'
        p userid, weight, location, time, fishid
        db.execute(query, userid, weight, location, time, fishid).first
        redirect '/'

    end

    
end