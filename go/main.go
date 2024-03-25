package main

import (
	"database/sql"
	"fmt"
	"log"
	"strconv"

	_ "github.com/mattn/go-sqlite3"
	"github.com/savsgio/atreugo/v11"
)

func main() {
	db, err := sql.Open("sqlite3", "./analytics.sqlite3")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	sqlStmt := `
CREATE TABLE IF NOT EXISTS visits (
id    INTEGER PRIMARY KEY,
user_agent TEXT NOT NULL,
referrer  TEXT NOT NULL);
pragma journal_mode=wal;
pragma synchronous=1;
pragma page_size = 4096;
	`
	_, err = db.Exec(sqlStmt)
	if err != nil {
		log.Printf("%q: %s\n", err, sqlStmt)
		return
	}

	config := atreugo.Config{
		Addr: "0.0.0.0:3030",
	}
	server := atreugo.New(config)

	server.GET("/hello", func(ctx *atreugo.RequestCtx) error {
		return ctx.TextResponse("Hello World!")
	})

	server.GET("/visit", func(ctx *atreugo.RequestCtx) error {
		_, err := db.Exec("INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar')")
		if err != nil {
			log.Printf("%q: %s\n", err, sqlStmt)
		}

		return ctx.TextResponse("OK")
	})

	server.GET("/stats", func(ctx *atreugo.RequestCtx) error {
		stmt, err := db.Prepare("SELECT MAX(id) FROM visits;")
		if err != nil {
			log.Fatal(err)
		}
		defer stmt.Close()

		var count int
		err = stmt.QueryRow().Scan(&count)
		if err != nil {
			return fmt.Errorf("scan failed while querying count: %v", err)
		}

		return ctx.TextResponse(strconv.Itoa(count))
	})

	if err := server.ListenAndServe(); err != nil {
		panic(err)
	}
}
