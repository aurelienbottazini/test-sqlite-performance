#!/usr/bin/env zsh

# for w in clojure clojurescript go js js-bun js-deno ruby rust
# do
#   cd $w
#   rm  -f ./analytics.sqlite3
#   rm  -f ./analytics.sqlite3-shm
#   rm  -f ./analytics.sqlite3-wal
#   sqlite3 analytics.sqlite3 < ../sql/setup_sqlite.sql
#   make build 1>/dev/null
#   make serve 1>/dev/null &
#   SERVER_PID=$!
#   echo "sleeping for 10 seconds to let server start"
#   sleep 10
#   echo "benchmarking /hello"
#   wrk -t12 -c400 -d30 http://0.0.0.0:3030/hello > ../stats/${w}_hello.txt
#   echo "benchmarking /visit"
#   wrk -t12 -c400 -d30 http://0.0.0.0:3030/visit > ../stats/${w}_visit.txt
#   echo "benchmarking /stats"
#   wrk -t12 -c400 -d30 http://0.0.0.0:3030/stats > ../stats/${w}_stats.txt
#   kill $SERVER_PID
#   cd ..
# done

for w in rails
do
  cd $w
  rm  -f ./db/*.sqlite3*
  make build 1>/dev/null
  make serve 1>/dev/null &
  SERVER_PID=$!
  echo "sleeping for 10 seconds to let server start"
  sleep 10
  echo "benchmarking /hello"
  wrk -t12 -c400 -d30 http://0.0.0.0:3030/hello > ../stats/${w}_hello.txt
  echo "benchmarking /visit"
  wrk -t12 -c400 -d30 http://0.0.0.0:3030/visit > ../stats/${w}_visit.txt
  echo "benchmarking /stats"
  wrk -t12 -c400 -d30 http://0.0.0.0:3030/stats > ../stats/${w}_stats.txt
  kill $SERVER_PID
  cd ..
done