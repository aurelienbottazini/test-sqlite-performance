import { serve } from "https://deno.land/std@0.159.0/http/server.ts";
import { DB } from "https://deno.land/x/sqlite/mod.ts";

const db = new DB("analytics.sqlite3");
db.execute("pragma mmap_size = 30000000000");
db.execute("pragma temp_store = MEMORY");

const prepareHello = db.prepareQuery(
  "INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar');",
);
const prepareStats = db.prepareQuery("SELECT MAX(id) FROM visits;");

serve(
  (request) => {
    let path = request.url.split("/");
    path = path[path.length - 1];

    if (path === "visit") {
      prepareHello.execute();
      return new Response(null, { status: 204 });
    } else if (path === "stats") {
      const result = prepareStats.first();
      return new Response(result[0]);
    } else {
      return new Response("Hello World!");
    }
  },
  { port: 3030 },
);
