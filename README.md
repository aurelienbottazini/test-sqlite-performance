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

