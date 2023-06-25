import { pipe } from 'fp-ts/function';
import * as TE from 'fp-ts/TaskEither';
import * as T from 'fp-ts/Task';
import { Database } from 'bun:sqlite';

const db = new Database('analytics.sqlite3');

// Execute the initial pragma statements and create table statement
pipe(
  TE.fromIO(() => db.run('pragma journal_mode = WAL')),
  TE.chain(() => TE.fromIO(() => db.run('pragma synchronous = 1'))),
  TE.chain(() => TE.fromIO(() => db.run('pragma page_size = 4096'))),
  TE.chain(() => TE.fromIO(() => db.run('pragma mmap_size = 30000000000'))),
  TE.chain(() => TE.fromIO(() => db.run('pragma temp_store = MEMORY'))),
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
  TE.fold(
    (error) => T.fromIO(() => console.error(`Error: ${error}`)),
    (_) => T.fromIO(() => console.log('Initial setup completed.'))
  )
)();

const insertQuery = () =>
  pipe(
    TE.fromIO(() => db.prepare("INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar');").run()),
    TE.fold(
      (error) => T.fromIO(() => console.error(`Error: ${error}`)),
      (_) => T.fromIO(() => console.log('Insert query executed.'))
    )
  );

const selectQuery = () =>
  pipe(
    TE.fromIO(() => db.prepare('SELECT MAX(id) FROM visits;').get()),
    TE.fold(
      (error) => T.fromIO(() => new Response(`Error: ${error}`)),
      (result) => T.fromIO(() => new Response(result['MAX(id)']))
    )
  );

export default {
  port: 3030,
  fetch(req: { url: string; }) {
    let urlPaths = req.url.split('/');
    let urlPath = urlPaths[urlPaths.length - 1];
    if (urlPath === 'visit') {
      insertQuery()();
      return new Response(null, { status: 204 });
    } else if (urlPath === 'stats') {
        return selectQuery()();
    } else {
      return new Response('Hello, World!');
    }
  },
};


