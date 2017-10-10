from flask import Flask
from flask import request
app = Flask(__name__)


@app.route("/")
def root():
    return "YO"


#  GET /jokes // Get all jokes
#  POST /jokes // Add a joke
@app.route("/jokes", methods=['GET', 'POST'])
def jokes():
    return 'jokes %s' % request.method


@app.route("/jokes/<int:id>", methods=['GET', 'PUT', 'DELETE'])
def jokes_id(id):
    return 'joke %s %s' % (id, request.method,)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
