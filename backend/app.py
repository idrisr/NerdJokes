from flask import Flask

NerdJokesApp = Flask(__name__)


@NerdJokesApp.route("/")
def hello():
    return "YO"

if __name__ == '__main__':
    NerdJokesApp.run(host='0.0.0.0', port=80)
