# NerdJokes backend

## IMPORTANT
- Currently the backend is only compatible with Swift 3.1

## Prerequisites (easily obtained with Homebrew)
- libxml2
- postgres

## Database setup
1. After installing postgres from homebrew start the database server:

```bash
$ brew services start postgresql
```

2. Create the database:

```bash
$ create user -D -P perfect

# put in "perfect" as your password

$ createdb -O perfect nerdjokes
```  
