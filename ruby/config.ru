# frozen_string_literal: true

require 'roda'
# require 'sequel'
require 'extralite'

DB = Extralite::Database.new('analytics.sqlite3')
DB.pragma(journal_mode: 'wal')
DB.pragma(synchronous: 'normal')
DB.pragma(page_size: '4096')
DB.pragma(mmap_size: '30000000000')

DB.execute("
CREATE TABLE IF NOT EXISTS visits (
id    INTEGER PRIMARY KEY,
user_agent TEXT NOT NULL,
referrer  TEXT NOT NULL);
")

class App < Roda
  insert_prepared = DB.prepare("INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar');")
  select_prepared = DB.prepare('SELECT MAX(id) as max FROM visits;')

  route do |r|
    r.is 'hello' do
      r.get do
        'Hello World!'
      end
    end

    r.is 'visit' do
      r.get do
        insert_prepared.query
        response.status = 204
        ''
      end
    end

    r.is 'stats' do
      r.get do
        count = DB.query_single_value('select MAX(id) as max from visits;')
        count = select_prepared.query_single_value
        count.to_s
      end
    end
  end
end

run App.freeze.app
