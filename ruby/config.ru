require 'roda'
require 'sequel'

DB = Sequel.sqlite('analytics.sqlite3')
DB.execute("
CREATE TABLE IF NOT EXISTS visits (
id    INTEGER PRIMARY KEY,
user_agent TEXT NOT NULL,
referrer  TEXT NOT NULL);
");

class App < Roda
insert_prepared = DB["INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar');"]
select_prepared = DB["SELECT MAX(id) as max FROM visits;"]

  route do |r|
    r.is 'hello' do
      r.get do
        'Hello World!'
      end
    end

    r.is 'visit' do
      r.get do
        insert_prepared.call(:insert)
        response.status = 204
        ''
      end
    end

    r.is 'stats' do
      r.get do
        count = select_prepared.call(:select)
        "#{count.first.max[1]}"
      end
    end
  end
end

run App.freeze.app
