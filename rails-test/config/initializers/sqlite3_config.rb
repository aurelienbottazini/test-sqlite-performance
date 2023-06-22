ActiveSupport::on_load(:active_record_sqlite3adapter) do

  module SQLitePragmaStatements

    # This configure_connection is run when each new connection is created.
    # see https://github.com/rails/rails/blob/main/activerecord/lib/active_record/connection_adapters/abstract_adapter.rb#L1112
    def configure_connection
      super

      puts "Configuring DB connection with app-specific PRAGMA statements"
      conn = self.raw_connection

      conn.synchronous = 1 # normal
      conn.journal_mode = 'wal'
      conn.foreign_keys = true
      conn.page_size = 4096
      conn.mmap_size = 30000000000
      conn.temp_store = 'memory'
    end
  end


  class ActiveRecord::ConnectionAdapters::SQLite3Adapter
    prepend SQLitePragmaStatements
  end

end
