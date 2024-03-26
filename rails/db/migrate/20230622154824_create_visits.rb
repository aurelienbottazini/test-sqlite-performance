class CreateVisits < ActiveRecord::Migration[7.0]
  def change
    create_table :visits do |t|
      t.string :referrer
      t.string :user_agent

      t.timestamps

      execute <<-SQL
      pragma journal_mode=wal;
      pragma synchronous=1;
      pragma page_size = 4096;
      SQL
    end
  end
end
