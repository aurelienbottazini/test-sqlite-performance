# frozen_string_literal: true

require 'roda'
require 'extralite'
require 'pg'

module Database
  module_function

  def backend
    ENV.fetch('DB_BACKEND', 'sqlite')
  end

  def insert
    adapter.insert
  end

  def max_id
    adapter.max_id
  end

  def adapter
    @adapter ||= case backend
    when 'sqlite'
                   SQLiteAdapter.new
    when 'postgres', 'postgresql'
                   PostgresAdapter.new
    else
                   raise "Unsupported DB_BACKEND=#{backend.inspect}"
    end
  end

  class SQLiteAdapter
    def initialize
      @db = Extralite::Database.new(ENV.fetch('SQLITE_DATABASE', 'analytics.sqlite3'), wal: true)
      @db.pragma(journal_mode: 'wal')
      @db.pragma(synchronous: '1')
      @db.pragma(page_size: '4096')
      @db.pragma(temp_store: 'memory')
      @db.pragma(mmap_size: '30000000000')
      @db.busy_timeout = 30
      @db.execute(<<~SQL)
        CREATE TABLE IF NOT EXISTS visits (
          id INTEGER PRIMARY KEY,
          user_agent TEXT NOT NULL,
          referrer TEXT NOT NULL
        );
      SQL
      @insert = @db.prepare("INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar');")
      @select = @db.prepare_splat('SELECT MAX(id) as max FROM visits;')
    end

    def insert
      @insert.reset
      @insert.next
    end

    def max_id
      @select.reset
      @select.next
    end
  end

  class PostgresAdapter
    INSERT_STATEMENT = 'insert_visit'
    SELECT_STATEMENT = 'select_max_visit_id'

    def initialize
      setup_connection = PG.connect(connection_options)
      setup_connection.exec('SELECT pg_advisory_lock(836_424_001)')
      begin
        setup_connection.exec(<<~SQL)
          CREATE UNLOGGED TABLE IF NOT EXISTS visits (
            id bigserial PRIMARY KEY,
            user_agent text NOT NULL,
            referrer text NOT NULL
          );
          ALTER TABLE visits SET UNLOGGED;
        SQL
      ensure
        setup_connection.exec('SELECT pg_advisory_unlock(836_424_001)')
        setup_connection.close
      end
    end

    def insert
      connection.exec_prepared(INSERT_STATEMENT)
    end

    def max_id
      connection.exec_prepared(SELECT_STATEMENT).getvalue(0, 0) || '0'
    end

    private

    def connection
      Thread.current[:postgres_connection] ||= begin
        conn = PG.connect(connection_options)
        conn.exec('SET synchronous_commit = off')
        conn.prepare(INSERT_STATEMENT, "INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar');")
        conn.prepare(SELECT_STATEMENT, 'SELECT last_value FROM visits_id_seq;')
        conn
      end
    end

    def connection_options
      ENV['DATABASE_URL'] || {
        host: ENV.fetch('POSTGRES_HOST', '127.0.0.1'),
        port: ENV.fetch('POSTGRES_PORT', '5432'),
        dbname: ENV.fetch('POSTGRES_DB', 'postgres'),
        user: ENV.fetch('POSTGRES_USER', 'postgres'),
        password: ENV.fetch('POSTGRES_PASSWORD', 'postgres')
      }
    end
  end
end

class App < Roda
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
          Database.insert
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
          count = Database.max_id
        rescue StandardError
          if (attempts += 1) < 100
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
