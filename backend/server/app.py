#!/usr/bin/env python3

'''
File: app.py
Author: idraja
Description: flask rest api endpoint for admin page and mobile clients
'''

from flask import Flask
from flask import abort
from flask import jsonify
from flask import render_template
from flask import request
from flask import send_from_directory

import os.path
import sqlite3 as sqlite
import sys

app = Flask(__name__)


@app.route("/jokes/<int:id>", methods=['GET'])
def get_joke(id):
    """get joke by id """
    joke = Joke.get(id)

    if joke is None:
        content = {'please move along': 'nothing to see here'}
        return abort(404)
    else:
        return jsonify(vars(joke))


@app.route("/jokes/<int:id>", methods=['PUT'])
def put_joke(id):
    """update joke by id """
    data = request.data
    #  convert into joke object
    #  update the appropriate fields
    #  send it back





    return ""


@app.route("/jokes/", methods=['POST'])
def create_joke():
    """create joke """
    pass


@app.route("/jokes/<int:id>", methods=['DELETE'])
def delete_joke(id):
    """delete joke by id"""
    pass


@app.route('/fonts/<path:path>')
def send_fonts(path):
    return send_from_directory('fonts', path)


@app.route('/js/<path:path>')
def send_js(path):
    return send_from_directory('js', path)


@app.route('/css/<path:path>')
def send_css(path):
    return send_from_directory('css', path)


@app.route("/jokes", methods=['GET'])
def get_jokes():
    """get all jokes"""
    # todo:  redirect to /
    return 'jokes %s' % request.method


@app.route("/", methods=['GET'])
def root():
    jokes = Joke.get_all()
    return render_template('index.html', jokes=jokes)


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
        self.table = Joke.table


    @classmethod
    def get_all(cls):
        query = "SELECT * FROM {}"
        query = query.format(cls.table)
        return QueryHelper.select(query)

    @classmethod
    def get(cls, id):
        query = "SELECT * FROM {} where ID = {}"
        query = query.format(cls.table, id)
        return QueryHelper.select(query)

    @classmethod
    def put(cls, data):
        id = data["id"]
        query = "SELECT * FROM {} where ID = {}"
        query = query.format(cls.table, id)
        joke = QueryHelper.select(query)
        update = vars(joke).update ( (k, v, ) for k, v in e.items() if v is not None)
        joke = Joke(update)

        query = '''update jokes set 
                    setup = {setup},
                    punchline = {punchline},
                    votes = {votes} 
                    '''


            }o}
        {"id":1,"setup":"why did the chicken cross the road","punchline":"because he wanted to die","votes":1}
        
        kkk"

        






class QueryHelper(object):
    database = "jokes.db"
    connection = sqlite.connect(database, check_same_thread = False)
    cursor = connection.cursor()


    @classmethod
    def update(query):
        pass


    @classmethod
    def delete(cls, query):
        pass


    @classmethod
    def select(cls, query):
        jokes = []
        for r in cls.cursor.execute(query):
            jokes.append(Joke(r))


        if len(jokes) == 1:
            return jokes[0]
        elif len(jokes) == 0:
            return None
        else:
            return jokes


    @classmethod
    def insert(cls, query):
        pass


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
