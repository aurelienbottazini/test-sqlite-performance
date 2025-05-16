serve:
	# WEB_CONCURRENCY=8 rackup --env production -o 0.0.0.0 -p 3030 -O Threads=0:8
	bundle exec falcon serve -n 5 --port 3030 -b http://0.0.0.0

build:
	bundle
