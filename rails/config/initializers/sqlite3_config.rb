ActiveSupport.on_load(:active_record_sqlite3adapter) do
  module SQLitePragmaStatements
    # This configure_connection is run when each new connection is created.
    # see https://github.com/rails/rails/blob/main/activerecord/lib/active_record/connection_adapters/abstract_adapter.rb#L1112
    def configure_connection
      super

      puts 'Configuring DB connection with app-specific PRAGMA statements'
      conn = raw_connection

      conn.mmap_size = 30_000_000_000
      conn.temp_store = 'memory'
    end
  end

  module SqliteTransactionFix
    # def begin_db_transaction
    # log('begin immediate transaction', nil) { @connection.transaction(:immediate) }
    # end
  end

  class ActiveRecord::ConnectionAdapters::SQLite3Adapter
    prepend SqliteTransactionFix
    prepend SQLitePragmaStatements
  end
end
