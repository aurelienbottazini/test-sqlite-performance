const http = require("http");
const db = require("better-sqlite3")("analytics.sqlite3");

db.pragma("mmap_size = 30000000000");
db.pragma("temp_store = MEMORY");

const prepareHello = db.prepare(
  "INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar');",
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
    res.end(result.toString());
  } else {
    res.writeHead(200);
    res.end("Hello, World!");
  }
};

const server = http.createServer(requestListener);
server.listen(3030);
