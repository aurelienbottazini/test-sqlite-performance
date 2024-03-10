#!/usr/bin/env zsh

echo "Ruby"
cd ruby
rm  -f ./analytics.sqlite3
rm  -f ./analytics.sqlite3-shm
rm  -f ./analytics.sqlite3-wal
make serve 1>/dev/null &
SERVER_PID=$!
echo "sleeping for 5 seconds to let server start"
sleep 5
echo "hello"
wrk -t12 -c400 -d30 http://0.0.0.0:3030/hello > ./hello.txt
echo "visit"
wrk -t12 -c400 -d30 http://0.0.0.0:3030/visit > ./visit.txt
echo "stats"
wrk -t12 -c400 -d30 http://0.0.0.0:3030/stats > ./stats.txt
kill $SERVER_PID
cd ..


echo "Go"
cd go
rm  -f ./analytics.sqlite3
rm  -f ./analytics.sqlite3-shm
rm  -f ./analytics.sqlite3-wal
make serve 1>/dev/null &
SERVER_PID=$!
echo "sleeping for 5 seconds to let server start"
sleep 5
echo "hello"
wrk -t12 -c400 -d30 http://0.0.0.0:3030/hello > ./hello.txt
echo "visit"
wrk -t12 -c400 -d30 http://0.0.0.0:3030/visit > ./visit.txt
echo "stats"
wrk -t12 -c400 -d30 http://0.0.0.0:3030/stats > ./stats.txt
kill $SERVER_PID
cd ..

echo "Rust"
cd rust
rm  -f ./analytics.sqlite3
rm  -f ./analytics.sqlite3-shm
rm  -f ./analytics.sqlite3-wal
make serve 1>/dev/null &
SERVER_PID=$!
echo "sleeping for 5 seconds to let server start"
sleep 5
echo "hello"
wrk -t12 -c400 -d30 http://0.0.0.0:3030/hello > ./hello.txt
echo "visit"
wrk -t12 -c400 -d30 http://0.0.0.0:3030/visit > ./visit.txt
echo "stats"
wrk -t12 -c400 -d30 http://0.0.0.0:3030/stats > ./stats.txt
kill $SERVER_PID
cd ..
