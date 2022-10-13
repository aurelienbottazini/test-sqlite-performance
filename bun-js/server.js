import { Database } from "bun:sqlite";
const db = new Database("analytics.sqlite3");

db.run("pragma journal_mode = WAL");
db.run("pragma synchronous = 1");
db.run("pragma page_size = 4096");
db.run("pragma mmap_size = 30000000000");
db.run("pragma temp_store = MEMORY");

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

export default {
  port: 3030,
  fetch(req) {
    let urlPath = req.url.split("/");
    urlPath = urlPath[urlPath.length - 1];
    if (urlPath === "visit") {
      prepareHello.run();
      return new Response(null, { status: 204 });
    } else if (urlPath === "stats") {
      const result = prepareStats.get();
      return new Response(JSON.stringify(result));
    } else {
      return new Response("Hello, World!");
    }
  },
};
