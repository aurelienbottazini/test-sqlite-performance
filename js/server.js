const http = require("http");
const db = require("better-sqlite3")("../analytics.sqlite3");

db.pragma("journal_mode = WAL");
db.pragma("synchronous = 1");
db.pragma("page_size = 4096");
db.pragma("mmap_size = 30000000000");
db.pragma("temp_store = MEMORY");

db.exec(`
CREATE TABLE IF NOT EXISTS visits (
id    INTEGER PRIMARY KEY,
user_agent TEXT NOT NULL,
referrer  TEXT NOT NULL);
`);

const prepareHello = db.prepare(
  "INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar');"
);
const prepareStats = db.prepare("SELECT MAX(id) FROM visits;");

const requestListener = function (req, res) {
  if (req.url === "/visit") {
    prepareHello.run();
    res.writeHead(204);
    res.end();
  } else if (req.url === "/stats") {
    const result = prepareStats.pluck().get();
    res.writeHead(200);
    res.end(JSON.stringify(result));
  } else {
    res.writeHead(200);
    res.end("Hello, World!");
  }
};

const server = http.createServer(requestListener);
server.listen(3030);
