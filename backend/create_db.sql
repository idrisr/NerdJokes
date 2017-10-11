CREATE TABLE
IF NOT EXISTS jokes (
    id integer PRIMARY KEY,
    setup text NOT NULL,
    punchline text NOT NULL,
    votes integer,
    created_time integer,
    updated_time integer,
    deleted_time integer
);
