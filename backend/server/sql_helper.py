import sqlite3 as sqlite

class QueryHelper(object):
    def __init__(self, database):
        self.datebase = database
        self.connection = sqlite.connect(database)
        self.cursor = connection.cursor()

    @classmethod
    def update(query):
        pass

    @classmethod
    def delete(cls, query):
        pass

    @classmethod
    def select(cls, query):
        pass

    @classmethod
    def insert(cls, query):
        pass

    @classmethod _execute_query(query):
        pass
