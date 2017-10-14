from flask import Flask
from flask import render_template
from flask import request
from flask import send_from_directory
import httplib
import os.path
import sqlite3 as sqlite
import sys


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
        sys.exit("unable to find database")

    conn = sqlite.connect('jokes.db')
    c = conn.cursor()
    jokes = []

    for r in c.execute('select * from jokes;'):
        jokes.append(Joke(r))

    return render_template('index.html', jokes=jokes)


#  GET /jokes // Get all jokes
#  POST /jokes // Add a joke
@app.route("/jokes", methods=['GET', 'POST'])
def jokes():
    return 'jokes %s' % request.method


@app.route("/jokes/<int:id>", methods=['GET', 'PUT', 'DELETE'])
def jokes_id(id):
    #  todo: reuse the connection
    conn = sqlite.connect('jokes.db')
    c = conn.cursor()

    request_json = request.get_json()

    if request.method == "PUT":
        vote_change = request_json["votes"]
        # todo: update the update time
        update_query = "UPDATE jokes SET votes = {} WHERE id = {}"\
            .format(vote_change, id)
        c.execute(update_query)
        conn.commit()

    elif request.method == "DELETE":
        # todo: set the delete flag, dont actually delete
        delete_query = "DELETE FROM jokes WHERE id = {}".format(id)
        c.execute(delete_query)
        conn.commit()
        conn.close()
        return ('', httplib.NO_CONTENT)

    if request.method == "PUT" or request.method == "GET":
        select_query = "SELECT * FROM jokes WHERE id = {}".format(id)
        joke = Joke(c.execute(select_query)[0])
        conn.close()
        return joke


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


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
