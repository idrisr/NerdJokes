#!/usr/bin/env python3


class Joke(object):
    table = "jokes"

    def __init__(self, result):
        self.id = result[0]
        self.setup = result[1]
        self.punchline = result[2]
        self.votes = result[3]
        self.created_time = result[4]
        self.updated_time = result[5]
        self.deleted_time = result[6]
        self.uuid = result[7]

    @classmethod
    def get(cls, id):
        query = "SELECT * FROM {} WHERE id = {}"
        query.format(cls.table, id)
        print(query)

    #  #  todo: reuse the connection
    #  conn = sqlite.connect('jokes.db')
    #  c = conn.cursor()

    #  request_json = request.get_json()

    #  if request.method == "PUT":
        #  vote_change = request_json["votes"]
        #  # todo: update the update time
        #  update_query = "UPDATE jokes SET votes = {} WHERE id = {}"\
        #  .format(vote_change, id)
        #  c.execute(update_query) conn.commit()

    #  elif request.method == "DELETE":
        #  # todo: set the delete flag, dont actually delete
        #  delete_query = "DELETE FROM jokes WHERE id = {}".format(id)
        #  c.execute(delete_query)
        #  conn.commit()
        #  conn.close()
        #  return ('', httplib.NO_CONTENT)

    #  if request.method == "PUT" or request.method == "GET":
        #  select_query = "SELECT * FROM jokes WHERE id = {}".format(id)
        #  joke = Joke(c.execute(select_query)[0])
        #  conn.close()
        #  return joke
