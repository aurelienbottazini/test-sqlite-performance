The goal of this repo is to test sqlite3 performance when used with a webserver.
I try to have implementations that are as fast as possible with as few dependencies as possible.

I am not an expert in all the languages tested.
I do my best effort to have a *reasonable* implementation.
I do my best to use each language properly and to find ways to make it fast in each language.

Server features:

- `/hello` to return an hello world string
- `/visits` to return a 204 no content reponse and save a `visit` in an sqlite table
- `/stats` to return a count from the visits table
