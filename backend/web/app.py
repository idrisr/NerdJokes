from flask import Flask
from flask import request
from pystache import render
import sqlite3 as sqlite
import json


app = Flask(__name__)


@app.route("/", methods=['GET'])
def root():
    conn = sqlite.connect('jokes.db')
    c = conn.cursor()
    jokes = {'jokes': []}

    template = open('webroot/main.mustache', 'r')

    for r in c.execute('select * from jokes;'):
        joke = Joke(r)
        jokes['jokes'].append(joke.toJson())

    return render(template.read(), json.dumps(jokes))


#  GET /jokes // Get all jokes
#  POST /jokes // Add a joke
@app.route("/jokes", methods=['GET', 'POST'])
def jokes():
    return 'jokes %s' % request.method


@app.route("/jokes/<int:id>", methods=['GET', 'PUT', 'DELETE'])
def jokes_id(id):
    return 'joke %s %s' % (id, request.method,)


class Joke(object):
    def __init__(self, result):
        self.id = result[0]
        self.setup = result[1]
        self.punchline = result[2]
        self.votes = result[3]
        self.created_time = result[4]
        self.updated_time = result[5]
        self.deleted_time = result[6]
        self.uuid = result[7]

    def toJson(self):
        return 'uuid: {uuid}, setup: {setup}, punchline: {punchline}, votes: {votes}'.format(**vars(self))


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
