(ns analytics.core
  (:require ["better-sqlite3" :as sqlite3]
            ["http" :as http]))

(set! *warn-on-infer* true)

(def db (sqlite3 "analytics.sqlite3"))
(.pragma db "journal_mode = WAL")
(.pragma db "synchronous = 1")
(.pragma db "page_size = 4096")
(.pragma db "mmap_size = 30000000000")
(.pragma db "temp_store = MEMORY")

(.exec db "
CREATE TABLE IF NOT EXISTS visits (
id    INTEGER PRIMARY KEY,
user_agent TEXT NOT NULL,
referrer  TEXT NOT NULL);
");

(def preparedHello (.prepare db "INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar')"))
(def preparedStats (.prepare db "SELECT MAX(id) FROM visits"))

(defn requestListener [req ^js res]
  (cond
    (= req.url "/visit") (do (.run preparedHello)
                             (.writeHead res 204)
                             (.end res "Hello World!"))
    (= req.url "/stats") (do (.writeHead res 200)
                             (.end res
                                   (str (.get (.pluck preparedStats)))))

    :else (do (.writeHead res 202)
              (.end res "Hello world!"))))

(defn main []
  (.listen (http/createServer requestListener) 3030))

