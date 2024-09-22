# frozen_string_literal: true

require 'roda'
require 'extralite'

DB = Extralite::Database.new('analytics.sqlite3', wal: true)
DB.pragma(journal_mode: 'wal')
DB.pragma(synchronous: '1')
DB.pragma(page_size: '4096')
DB.pragma(temp_store: 'memory')
DB.pragma(mmap_size: '30000000000')

class App < Roda
  insert_prepared = DB.prepare("INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar');")
  select_prepared = DB.prepare_splat('SELECT MAX(id) as max FROM visits;')

  route do |r|
    r.is 'hello' do
      r.get do
        'Hello World!'
      end
    end

    r.is 'visit' do
      r.get do
        begin
          attempts ||= 1
          insert_prepared.reset
          insert_prepared.next
        rescue StandardError
          if (attempts += 1) < 5
            retry
          end
          raise 'Failed to insert'
        end
        'OK'
      end
    end

    r.is 'stats' do
      r.get do
        count = nil
        begin
          attempts ||= 1
          select_prepared.reset
          count = select_prepared.next
        rescue StandardError
          if (attempts += 1) < 5
            retry
          end
          raise 'Failed to select'
        end
        count.to_s
      end
    end
  end
end

run App.freeze.app
