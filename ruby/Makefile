POSTGRES_SOCKET_DIR ?= /tmp/sqlite-perf-postgres

serve:
	RUBY_YJIT_ENABLE=1 WEB_CONCURRENCY=8 rackup --env production -o 0.0.0.0 -p 3030 -O Threads=0:8
	# bundle exec falcon serve -n 5 --port 3030 -b http://0.0.0.0

serve-postgres:
	DB_BACKEND=postgres RUBY_YJIT_ENABLE=1 WEB_CONCURRENCY=8 rackup --env production -o 0.0.0.0 -p 3030 -O Threads=0:8

serve-postgres-socket:
	POSTGRES_HOST=$(POSTGRES_SOCKET_DIR) DB_BACKEND=postgres RUBY_YJIT_ENABLE=1 WEB_CONCURRENCY=8 rackup --env production -o 0.0.0.0 -p 3030 -O Threads=0:8

postgres:
	docker run --rm --name sqlite-perf-postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres

postgres-socket:
	mkdir -p $(POSTGRES_SOCKET_DIR)
	docker run --rm --name sqlite-perf-postgres-socket -e POSTGRES_PASSWORD=postgres -v $(POSTGRES_SOCKET_DIR):/var/run/postgresql -d postgres

postgres-stop:
	docker stop sqlite-perf-postgres

postgres-socket-stop:
	docker stop sqlite-perf-postgres-socket

build:
	bundle
