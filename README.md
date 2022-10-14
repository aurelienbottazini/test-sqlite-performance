The goal of this repo is to simulate a small analytics server.

This analytics server can:

- return hello world
- register `visits` (think of a website using an URL to register user visits)
- return `stats` (the total number of visits)

Data is persisted with sqlite3.

The goal is to compage language and framework speed.
I don't want something complicated with a ton of dependencies.
But I do want to check the cost of making a database query and how this plays with concurrency.
