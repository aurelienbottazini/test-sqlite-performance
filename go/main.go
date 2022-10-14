package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"

	_ "github.com/mattn/go-sqlite3"
)

func hello(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "hello world!\n")
}

func visit(db *sql.DB, sqlStmt string) http.HandlerFunc {
	return func(w http.ResponseWriter, req *http.Request) {
		_, err := db.Exec(sqlStmt)
		if err != nil {
			log.Printf("%q: %s\n", err, sqlStmt)
			return
		}

		w.WriteHeader(http.StatusNoContent)
	}

}
func stats(db *sql.DB, sqlStmt string) http.HandlerFunc {
	return func(w http.ResponseWriter, req *http.Request) {
		var count int
		err := db.QueryRow(sqlStmt).Scan(&count)
		if err != nil {
			log.Fatal(err)
		}

		fmt.Fprintln(w, count)
	}

}

func main() {
	db, err := sql.Open("sqlite3", "./analytics.sqlite3?_journal_mode=wal&_synchronous=1")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	sqlStmt := `
CREATE TABLE IF NOT EXISTS visits (
id    INTEGER PRIMARY KEY,
user_agent TEXT NOT NULL,
referrer  TEXT NOT NULL);
pragma page_size = 4096;
pragma mmap_size = 30000000000;
pragma temp_store = MEMORY;
	`
	_, err = db.Exec(sqlStmt)
	if err != nil {
		log.Printf("%q: %s\n", err, sqlStmt)
		return
	}

	http.HandleFunc("/hello", hello)
	http.HandleFunc("/visit", visit(db, "INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar')"))
	http.HandleFunc("/stats", stats(db, "SELECT MAX(id) FROM visits;"))

	http.ListenAndServe("0.0.0.0:3030", nil)
}
