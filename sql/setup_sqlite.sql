CREATE TABLE IF NOT EXISTS visits (
id    INTEGER PRIMARY KEY,
user_agent TEXT NOT NULL,
host TEXT,
referrer  TEXT NOT NULL);
pragma journal_mode=wal;
pragma synchronous=1;
pragma page_size = 4096;
