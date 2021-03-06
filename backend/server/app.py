#!/usr/bin/env python3

'''
File: app.py
Author: idraja
Description: flask rest api endpoint for admin page and mobile clients
'''

from flask import abort
from flask import Flask
from flask import jsonify
from flask import render_template
from flask import request
from flask import send_from_directory

import logging
from logging.handlers import RotatingFileHandler

import sqlite3 as sqlite
import time

app = Flask(__name__)


@app.route("/jokes/<int:id>", methods=['GET'])
def get_joke(id):
    """get joke by id """
    joke = Joke.get(id)

    if joke is None:
        return abort(404)
    else:
        return jsonify(vars(joke))


@app.route("/jokes/<int:id>", methods=['PUT'])
def put_joke(id):
    """update joke by id """
    data = request.get_json()
    app.logger.info(data)
    joke = Joke.put(data)

    if joke is None:
        return abort(404)
    else:
        return jsonify(vars(joke))


@app.route("/jokes/", methods=['GET'])
@app.route("/jokes", methods=['GET'])
def jokes():
    """get all jokes"""
    jokes = Joke.get_all()
    return jsonify([vars(joke) for joke in jokes])


@app.route("/jokes/", methods=['POST'])
@app.route("/jokes", methods=['POST'])
def create_joke():
    """create joke """
    data = request.get_json()
    app.logger.info(data)

    if Joke.required_keys.issubset(data):
        joke = Joke(data)
        joke = joke.create_new()
        # pylint: disable=no-member
        response = jsonify({"id": joke.id})
        response.status_code = 201
        return response

    else:
        error = {"message": "creating a new jokes requires a punchline and\
                setup"}
        return (jsonify(error), 404)


@app.route("/jokes/<int:id>", methods=['DELETE'])
def delete_joke(id):
    """delete joke by id"""
    joke = Joke.get(id)
    if joke is not None:
        joke.delete()
        return ('', 204)
    else:
        message = {"message": "joke not found", "id": id}
        return jsonify(message, 400)


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
    required_keys = {"setup", "punchline"}

    def __init__(self, result):
        needed_keys = {'setup', 'punchline'}

        if needed_keys.issubset(result):
            self.setup = result["setup"]
            self.punchline = result["punchline"]

        else:
            i_vars = ["id", "setup", "punchline", "votes", "created_time",
                      "updated_time", "deleted_time", "deleted_flag"]

            #  todo: catch what happens when result doesnt have what is expected
            [setattr(self, i_var, result[i_var]) for i_var in i_vars]

    def create_new(self):
        #  insert a new object into the database
        #  INSERT INTO table1 ( column1, column2 ,..)
        #  VALUES ( value1, value2 ,...);

        d = {"table": self.__class__.table,
             "setup": self.setup,
             "punchline": self.punchline,
             "votes": 0,
             "created_time": int(time.time()),
             "updated_time": int(time.time()),
             "deleted_time": int(time.time()),
             "deleted_flag": 0}

        query = '''INSERT INTO {table}
        (setup, punchline, votes, created_time, updated_time, deleted_time,
        deleted_flag)
        VALUES
        ("{setup}", "{punchline}", {votes}, {created_time}, {updated_time},
        {deleted_time}, {deleted_flag})
        '''

        query = query.format(**d)
        return QueryHelper.insert(query)

    def delete(self):
        query = '''UPDATE {table} SET
                    deleted_time = {deleted_time},
                    deleted_flag = {deleted_flag}
                    WHERE id = {id};
                    '''
        # pylint: disable=no-member
        d = {"deleted_time": int(time.time()),
             "deleted_flag": 1,
             "id": self.id,
             "table": self.__class__.table}

        query = query.format(**d)
        return QueryHelper.update(query, id, False)

    def update(self, data):
        for k, v in data.items():
            if hasattr(self, k):
                setattr(self, k, v)

    def __repr__(self):
        d = vars(self)
        return ", ".join("%s: %s" % (k, v, ) for k, v in d.items())

    @classmethod
    def get_all(cls):
        query = '''SELECT *
                   FROM {}
                   WHERE deleted_flag = 0
                   ORDER BY updated_time DESC;
                '''
        query = query.format(cls.table)
        return QueryHelper.select(query)

    @classmethod
    def get(cls, id):
        query = '''SELECT *
                   FROM {}
                   WHERE id = {}
                   AND deleted_flag = 0;
                 '''
        query = query.format(cls.table, id)
        return QueryHelper.select(query)

    @classmethod
    def put(cls, data):
        id = data["id"]
        joke = cls.get(id)
        app.logger.info(joke)
        app.logger.info(data)

        joke.update(data)
        joke.updated_time = int(time.time())

        query = '''UPDATE jokes SET
                    setup = "{setup}",
                    punchline = "{punchline}",
                    votes = {votes},
                    updated_time = {updated_time}
                    WHERE id = {id};
                    '''

        query = query.format(**vars(joke))
        return QueryHelper.update(query, id)


class QueryHelper(object):
    database = "jokes.db"
    connection = sqlite.connect(database, check_same_thread=False)
    connection.row_factory = sqlite.Row
    cursor = connection.cursor()

    @classmethod
    def update(cls, query, id, returnNewObject=True):
        app.logger.info(query)
        cls.cursor.execute(query)

        if returnNewObject:
            return Joke.get(id)

    @classmethod
    def select(cls, query):
        app.logger.info(query)
        jokes = []

        #  todo - how does this work without a fetch?
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
        app.logger.info(query)
        cls.cursor.execute(query)
        return Joke.get(cls.cursor.lastrowid)


if __name__ == '__main__':
    handler = RotatingFileHandler('foo.log', maxBytes=10000, backupCount=1)
    handler.setLevel(logging.INFO)
    app.logger.addHandler(handler)
    app.run(host='0.0.0.0', port=80)
