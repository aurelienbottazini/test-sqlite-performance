# frozen_string_literal: true

require 'roda'
require 'sequel'

CONN = Sequel.sqlite(database: 'analytics.sqlite3').connect({})
CONN.synchronous = :normal
CONN.journal_mode = :wal
CONN.page_size = 4096
CONN.mmap_size = 30_000_000_000
CONN.execute("
CREATE TABLE IF NOT EXISTS visits (
id    INTEGER PRIMARY KEY,
user_agent TEXT NOT NULL,
referrer  TEXT NOT NULL);
")

class App < Roda
  insert_prepared = CONN.prepare("INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar');")
  select_prepared = CONN.prepare('SELECT MAX(id) as max FROM visits;')

  route do |r|
    r.is 'hello' do
      r.get do
        'Hello World!'
      end
    end

    r.is 'visit' do
      r.get do
        insert_prepared.execute
        response.status = 204
        ''
      end
    end

    r.is 'stats' do
      r.get do
        count = select_prepared.execute.next[0]
        "#{count}"
      end
    end
  end
end

run App.freeze.app
