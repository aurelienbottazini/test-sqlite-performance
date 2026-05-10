serve:
	RUBY_YJIT_ENABLE=1 WEB_CONCURRENCY=8 rackup --env production -o 0.0.0.0 -p 3030 -O Threads=0:8
	# bundle exec falcon serve -n 5 --port 3030 -b http://0.0.0.0

serve-postgres:
	DB_BACKEND=postgres RUBY_YJIT_ENABLE=1 WEB_CONCURRENCY=8 rackup --env production -o 0.0.0.0 -p 3030 -O Threads=0:8

postgres:
	docker run --rm --name sqlite-perf-postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres

postgres-stop:
	docker stop sqlite-perf-postgres

build:
	bundle
