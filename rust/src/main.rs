#![deny(warnings)]

use std::{str::FromStr, time::Duration};

use actix_cors::Cors;
use actix_web::{get, web, App, HttpRequest, HttpResponse, HttpServer, Responder};
use actix_web_static_files::ResourceFiles;
use sqlx::{
    sqlite::{SqliteConnectOptions, SqliteJournalMode, SqlitePoolOptions, SqliteSynchronous},
    Pool,
};

include!(concat!(env!("OUT_DIR"), "/generated.rs"));

#[get("/hello")]
async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello world!")
}

#[get("/visit")]
async fn visit(pool: web::Data<Pool<sqlx::Sqlite>>, req: HttpRequest) -> impl Responder {
    let agent = match req.headers().get("user-agent") {
        Some(agent) => agent.to_str().unwrap_or("unknown"),
        None => "unknown",
    };
    let referrer = match req.headers().get("referer") {
        Some(host) => host.to_str().unwrap_or("unknown"),
        None => "unknown",
    };

    sqlx::query("INSERT INTO visits (user_agent, referrer) VALUES (?, ?);")
        .bind(agent)
        .bind(referrer)
        .execute(&**pool)
        .await
        .expect("failed to insert");
    HttpResponse::NoContent()
}

#[get("/stats")]
async fn stats(pool: web::Data<Pool<sqlx::Sqlite>>) -> impl Responder {
    let row: (i64,) = sqlx::query_as("SELECT MAX(id) from visits;")
        .bind(150_i64)
        .fetch_one(&**pool)
        .await
        .expect("failed count");

    HttpResponse::Ok().body(format!("{}", row.0))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let database_file = "analytics.sqlite3";
    let database_url = format!("sqlite://{}", database_file);
    let pool_timeout = Duration::from_secs(30);

    let connection_options = SqliteConnectOptions::from_str(&database_url)
        .expect("connection options")
        .create_if_missing(true)
        .journal_mode(SqliteJournalMode::Wal)
        .synchronous(SqliteSynchronous::Normal)
        .page_size(4096)
        .pragma("mmap_size", "30000000000")
        .pragma("temp_store", "2")
        .busy_timeout(pool_timeout);

    let pool = SqlitePoolOptions::new()
        .max_connections(6)
        .connect_with(connection_options)
        .await
        .expect("create pool");

    sqlx::query(
        "
        CREATE TABLE IF NOT EXISTS visits (
        id    INTEGER PRIMARY KEY,
        user_agent TEXT NOT NULL,
        referrer  TEXT NOT NULL);",
    )
    .execute(&pool)
    .await
    .expect("create visits table");

    HttpServer::new(move || {
        let cors = Cors::default()
            .allow_any_origin()
            .allow_any_method()
            .allow_any_header();

        let generated = generate();
        App::new()
            .wrap(cors)
            .app_data(web::Data::new(pool.clone()))
            .service(visit)
            .service(stats)
            .service(hello)
            .service(ResourceFiles::new("/", generated))
    })
    .bind(("0.0.0.0", 3030))?
    .run()
    .await
}
