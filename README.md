The goal of this repo is to test sqlite3 performance when used with a webserver.
I try to have implementations that are as fast as possible with as few dependencies as possible.

I am not an expert in all the languages tested.
I do my best effort to have a *reasonable* implementation.
I did try to use each language properly and to find ways to make it fast.
If I failed it is also a sign the language is not that simple to use in a performant way.
I was able in at least some of the languages to serve for each case scenario to serve millions of request/30 seconds.

Server features:

- `/hello` to return an hello world string
- `/visits` to return a 204 no content reponse and save a `visit` in an sqlite table
- `/stats` to return a count from the visits table

## Run

- cd inside language directory
- `make build`
- `make serve`

## Test commands

- `wrk -t12 -c400 -d30 http://0.0.0.0:3030/hello`
- `wrk -t12 -c400 -d30 http://0.0.0.0:3030/visit`
- `wrk -t12 -c400 -d30 http://0.0.0.0:3030/stats`

## Results

### ClojureScript

- hello: 2.146.785
- #3 visit: 1.272.862
- stats: 1.681.424

### Rust 2021

Memory does not go up after successive runs. 16 Mo

- #2 hello: 4.665.344
- visit: 599.205
- #2 stats: 1.748.789

### Clojure

- hello: 2.829.808
- visit: 88.600
- #3 stats: 1.705.588

### js node 18.15.0

- hello: 2.007.203
- #2 visit: 1.293.715
- stats: 1.794.942

### bun 0.6.8

- #1 hello: 4.707.980, memory: 38 Mo
- #1 visit: 1.571.157, memory: 45 Mo
- #1 stats: 2.611.391, memory: 31 Mo -> memory grows after several runs

### deno 1.34.2

- hello: 1.857.104
- visit: 2.595
- stats: 782.207

### Ruby

- hello: 1.710.789
- visit: 556.532
- stats: 1.483.998

### Go 1.18.1

- #3 hello: 4.518.796
- visit: crashes
- stats: did not test because of visit crash
