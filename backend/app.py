from flask import Flask
from flask import request
from flask import url_for
from flask import send_from_directory
from pystache import render
import sqlite3 as sqlite
import json
import sys
import os.path

app = Flask(__name__)


@app.route('/fonts/<path:path>')
def send_fonts(path):
    return send_from_directory('fonts', path)


@app.route('/js/<path:path>')
def send_js(path):
    return send_from_directory('js', path)


@app.route('/css/<path:path>')
def send_css(path):
    return send_from_directory('css', path)


@app.route("/", methods=['GET'])
def root():
    if not os.path.isfile('jokes.db'):
        sys.exit()

    conn = sqlite.connect('jokes.db')
    c = conn.cursor()
    jokes = {'jokes': []}

    with open('main.mustache', 'r') as template_file:
        template = template_file.read()

    for r in c.execute('select * from jokes;'):
        joke = Joke(r)
        jokes['jokes'].append(joke.toJson())

    jokes_json = json.dumps(jokes)

    return render(template, jokes_json)


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
        return vars(self) 

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
