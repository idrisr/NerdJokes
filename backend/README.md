# NerdJokes backend

## IMPORTANT
- Currently the backend is only compatible with Swift 3.1

## Database setup
1. Create an empty SQLite3 database.
2. Point the database path constant in AppConstants to the full absolute path.

## Web app
- Web app is at path ``/html/jokes``

## API Reference
```javascript
  GET /jokes // Get all jokes
  GET /jokes/{id} // Get joke with id {id}
  POST /jokes // Add a joke
  PUT /jokes/{id} // Update a joke with id {id}
  DELETE /jokes/{id} // Delete a joke with id {id}
  GET /jokes/test/now // Add a test entry and return a list of entries

  // JSON body request for PUT/POST:
  {
    id: number, // only for PUT
    setup: string, // default value ""
    punchline: string, // default value ""
    votes: number // default value 0
  }
```

# Start web server

1. download and install docker if you don't have it from [here](https://docs.docker.com/engine/installation/)
or on mac do a `brew install docker`

1. run script `./docker_restart`

1. go to `localhost`
