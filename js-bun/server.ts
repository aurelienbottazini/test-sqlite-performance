import { pipe } from "fp-ts/function";
import * as TE from "fp-ts/TaskEither";
import * as T from "fp-ts/Task";
import { Database, Statement } from "bun:sqlite";
import { createPool, Pool, PoolOptions, Resource } from "generic-pool";

// Create a resource factory for the database connections
const resourceFactory: Resource<Database> = {
  create: () => Promise.resolve(new Database("analytics.sqlite3")),
  destroy: (db: Database) => Promise.resolve(db.close()),
};

// Configure the connection pool options
const poolOptions: PoolOptions<Database> = {
  max: 10, // Maximum number of connections in the pool
  min: 2, // Minimum number of connections in the pool
  idleTimeoutMillis: 30000, // Time in milliseconds after which idle connections will be removed from the pool
};

// Create the connection pool
const connectionPool: Pool<Database> = createPool(resourceFactory, poolOptions);

// Execute the initial pragma statements and create table statement
pipe(
  TE.fromIO(() => connectionPool.acquire()),
  TE.chain((db) =>
    pipe(
      TE.fromIO(() => db.run("pragma journal_mode = WAL")),
      TE.chain(() => TE.fromIO(() => db.run("pragma synchronous = 1"))),
      TE.chain(() => TE.fromIO(() => db.run("pragma page_size = 4096"))),
      TE.chain(() => TE.fromIO(() => db.run("pragma mmap_size = 30000000000"))),
      TE.chain(() => TE.fromIO(() => db.run("pragma temp_store = MEMORY"))),
      TE.chain(() =>
        TE.fromIO(() =>
          db.exec(`
            CREATE TABLE IF NOT EXISTS visits (
              id    INTEGER PRIMARY KEY,
              user_agent TEXT NOT NULL,
              referrer  TEXT NOT NULL
            );
          `)
        )
      ),
      TE.chainFirst(() => TE.fromIO(() => connectionPool.release(db))),
      TE.fold(
        (error) => T.fromIO(() => console.error(`Error: ${error}`)),
        (_) => T.fromIO(() => console.log("Initial setup completed."))
      )
    )
  )
)();

const insertQuery = () =>
  pipe(
    TE.tryCatch(
      () =>
        connectionPool.use((db) =>
          db.prepare(
            "INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar');"
          )
        ),
      (error) => `Error: ${error}`
    ),
    TE.chain((statement) =>
      TE.tryCatch(
        () =>
          connectionPool.use((db) =>
            db.transaction(() => statement.run()).commit()
          ),
        (error) => `Error: ${error}`
      )
    ),
    TE.fold(
      (error) => T.fromIO(() => console.error(error)),
      (_) => T.fromIO(() => console.log("Insert query executed."))
    )
  );

const selectQuery = () =>
  pipe(
    TE.tryCatch(
      () =>
        connectionPool.use((db) =>
          db.prepare("SELECT MAX(id) FROM visits;").get()
        ),
      (error) => `Error: ${error}`
    ),
    TE.fold(
      (error) => T.fromIO(() => new Response(`Error: ${error}`)),
      (result) => T.fromIO(() => new Response(result["MAX(id)"]))
    )
  );

export default {
  port: 3030,
  fetch(req: { url: string }) {
    let urlPaths = req.url.split("/");
    let urlPath = urlPaths[urlPaths.length - 1];
    if (urlPath === "visit") {
      insertQuery()();
      return new Response(null, { status: 204 });
    } else if (urlPath === "stats") {
      return selectQuery()();
    } else {
      return new Response("Hello, World!");
    }
  },
};
