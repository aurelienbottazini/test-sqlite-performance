(ns analytics.core
  (:gen-class)
  (:import com.mchange.v2.c3p0.ComboPooledDataSource)
  (:require [reitit.ring :as ring]
            [org.httpkit.server :as hk-server]
            [clojure.java.jdbc :as j]))

(def db-spec
  {:classname "org.sqlite.JDBC"
   :subprotocol "sqlite"
   :subname "//analytics.sqlite3"
   })

(defn pool
  [spec]
  (let [cpds (doto (ComboPooledDataSource.)
               (.setDriverClass (:classname spec))
               (.setJdbcUrl (str "jdbc:sqlite:analytics.sqlite3"))
               (.setInitialPoolSize 6)
               (.setMinPoolSize 6)
               (.setMaxPoolSize 6)
               ;; expire excess connections after 30 minutes of inactivity:
               (.setMaxIdleTimeExcessConnections (* 30 60))
               ;; expire connections after 3 hours of inactivity:
               (.setMaxIdleTime (* 3 60 60)))]
    {:datasource cpds}))

(def pooled-db (delay (pool db-spec)))
(defn db-connection [] @pooled-db)

(defn visit [_request]
(let [conn (db-connection)]
  (j/execute! conn  "INSERT INTO visits (user_agent, referrer) VALUES (\"foo\", \"bar\");"))
  {:status 204})

(defn stats [_request]
(let [conn (db-connection)
result (j/query conn "SELECT MAX(id) as max from visits;")]
  {:status 200
   :body (str (:max (first result)))}))

(defn hello [_request]
  {:status 200
   :body "Hello World!"})

(def app
  (ring/ring-handler
    (ring/router
      [["/stats" {:get { :handler stats}}]
       ["/visit" {:get { :handler visit}}]
       ["/hello" {:get { :handler hello}}]])))

(defn -main [& _args]
  (let [conn (db-connection)]
    (j/execute! conn "pragma temp_store = memory;")
    (j/query conn "pragma mmap_size = 30000000000;")
    (hk-server/run-server app {:port 3030})))
