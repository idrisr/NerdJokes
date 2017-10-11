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

INSERT INTO jokes (setup, punchline, votes, created_time, updated_time, deleted_time)
VALUES
("why did the chicken cross the road", "because he wanted to die", 0,  strftime('%s', 'now'), strftime('%s', 'now'), strftime('%s', 'now')) 
;
