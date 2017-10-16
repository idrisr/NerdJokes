#!/usr/bin/env python3

'''
File: app.py
Author: idraja
Description: flask rest api endpoint for admin page and mobile clients
'''

from flask import Flask
from flask import render_template
from flask import request
from flask import send_from_directory

#  from joke import Joke

import os.path
import sqlite3 as sqlite
import sys

app = Flask(__name__)


@app.route("/jokes/<int:id>", methods=['GET'])
def get_joke(id):
    """get joke by id """
    #  Joke.get(id)
    pass


@app.route("/jokes/<int:id>", methods=['PUT'])
def update_joke(id):
    """update joke by id """
    pass


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
    if not os.path.isfile('jokes.db'):
        sys.exit("unable to find database")

    conn = sqlite.connect('jokes.db')
    c = conn.cursor()
    jokes = []

    #  for r in c.execute('select * from jokes;'):
    #  jokes.append(Joke(r))

    return render_template('index.html', jokes=jokes)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
