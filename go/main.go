package main

import (
	"fmt"
	"log"
	"strconv"

	"github.com/bvinc/go-sqlite-lite/sqlite3"
	"github.com/savsgio/atreugo/v11"
)

func main() {
	conn, err := sqlite3.Open("./analytics.sqlite3")
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	sqlStmt := `
CREATE TABLE IF NOT EXISTS visits (
id    INTEGER PRIMARY KEY,
user_agent TEXT NOT NULL,
referrer  TEXT NOT NULL);
pragma journal_mode=wal;
pragma synchronous=1;
pragma page_size = 4096;
pragma mmap_size = 30000000000;
pragma temp_store = MEMORY;
	`
	err = conn.Exec(sqlStmt)
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

	server.GET("/visits", func(ctx *atreugo.RequestCtx) error {
		err := conn.Exec("INSERT INTO visits (user_agent, referrer) VALUES ('foo', 'bar')")
		if err != nil {
			log.Printf("%q: %s\n", err, sqlStmt)
		}

		return ctx.TextResponse("OK")
	})

	server.GET("/stats", func(ctx *atreugo.RequestCtx) error {
		stmt, err := conn.Prepare("SELECT MAX(id) FROM visits;")
		if err != nil {
			log.Fatal(err)
		}
		defer stmt.Close()

		_, err = stmt.Step()
		if err != nil {
			return fmt.Errorf("step failed while querying count: %v", err)
		}
		var count int
		err = stmt.Scan(&count)
		if err != nil {
			return fmt.Errorf("scan failed while querying count: %v", err)
		}

		return ctx.TextResponse(strconv.Itoa(count))
	})

	if err := server.ListenAndServe(); err != nil {
		panic(err)
	}
}
