(ns analytics.core
  (:import com.mchange.v2.c3p0.ComboPooledDataSource)
  (:require [ring.adapter.jetty :as jetty] 
             [reitit.ring :as ring]
             [clojure.java.jdbc :as j]
             ))

(def db-spec
  {:classname "org.sqlite.JDBC"
   :subprotocol "sqlite"
   :subname "//analytics.sqlite3"
   })

(defn pool
  [spec]
  (let [cpds (doto (ComboPooledDataSource.)
               (.setDriverClass (:classname spec))
              ;;  (.setJdbcUrl (str "jdbc:" (:subprotocol spec) ":" (:subname spec)))
               (.setJdbcUrl (str "jdbc:sqlite:analytics.sqlite3"))
               (.setInitialPoolSize 20)
               (.setMinPoolSize 20)
               (.setMaxPoolSize 20)
               ;; expire excess connections after 30 minutes of inactivity:
               (.setMaxIdleTimeExcessConnections (* 30 60))
               ;; expire connections after 3 hours of inactivity:
               (.setMaxIdleTime (* 3 60 60)))]
    {:datasource cpds}))

(def pooled-db (delay (pool db-spec)))
(defn db-connection [] @pooled-db)

(defn hello [_request]
(let [conn (db-connection)]
  (j/execute! conn  "INSERT INTO visits (user_agent, host) VALUES (\"foo\", \"bar\");"))
  {:status 204})

(defn stats [_request]
(let [conn (db-connection)
result (j/query conn "SELECT MAX(id) as max from visits;")]
  {:status 200
   :body (str "<html><header></header><body>Stats: " (:max (first result)) "</body></html>")}))

(def app
(ring/ring-handler
(ring/router
[["/stats" {:get { :handler stats}}]
["/hello" {:get { :handler hello}}]])))

(defn -main [& _args]
  (let [conn (db-connection)]
    (j/execute! conn "pragma temp_store = memory;")
    ;; (j/execute! conn "pragma mmap_size = 30000000000;")
    (j/execute! conn "pragma page_size = 4096;")
    (j/execute! conn "CREATE TABLE IF NOT EXISTS visits (
        id    INTEGER PRIMARY KEY,
        user_agent TEXT NOT NULL,
        host  TEXT NOT NULL);"))
  (jetty/run-jetty app {:port 3000}))
