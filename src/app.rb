class App < Sinatra::Base


    @loggedin = 1

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

    
end