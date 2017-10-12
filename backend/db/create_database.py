import sqlite3

# create a database file named 'people.db' if it doesn't exist yet.
# if this file already exists, then the program will quit.
conn = sqlite3.connect('nerdjokes.db')
c = conn.cursor()

# create a new 'users' table with three columns: name, age, image
c.execute('create table jokes(name varchar(100) primary key, age integer, image varchar(100))')

# insert 3 rows of data into the 'users' table
c.execute("insert into users values('Philip', 30, '../cat.jpg');")
c.execute("insert into users values('John', 25, '../dog.jpg');")
c.execute("insert into users values('Jane', 40, '../bear.jpg');")

# commit ('save') the transaction and close the connection
conn.commit()
conn.close()
