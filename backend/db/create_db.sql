CREATE TABLE
IF NOT EXISTS jokes (
    id integer PRIMARY KEY,
    setup text NOT NULL,
    punchline text NOT NULL,
    votes integer,
    created_time integer,
    updated_time integer,
    deleted_time integer,
    deleted_flag bool integer -- sqlite has no bool, so int it is
);

INSERT INTO jokes (setup, punchline, votes, created_time, updated_time, deleted_time, deleted_flag)
VALUES
("why did the chicken cross the road" , "because he wanted to die"               , 0 , strftime('%s' , 'now') , strftime('%s' , 'now') , strftime('%s' , 'now') ,  0) ,
("why did the chicken cross the road" , "because he wanted to live"              , 0 , strftime('%s' , 'now') , strftime('%s' , 'now') , strftime('%s' , 'now') ,  0) ,
("why did the chicken cross the road" , "because his uber was on the wrong side" , 0 , strftime('%s' , 'now') , strftime('%s' , 'now') , strftime('%s' , 'now') ,  0) ,
("why did the turkey cross the road"  , "because god told him to"                , 0 , strftime('%s' , 'now') , strftime('%s' , 'now') , strftime('%s' , 'now') ,  0) ,
("why did the chicken cross the road" , "the world has no answers"               , 0 , strftime('%s' , 'now') , strftime('%s' , 'now') , strftime('%s' , 'now') ,  0) ,
("why did the chicken cross the road" , "there are no answers here. move on."    , 0 , strftime('%s' , 'now') , strftime('%s' , 'now') , strftime('%s' , 'now') ,  0)
;
