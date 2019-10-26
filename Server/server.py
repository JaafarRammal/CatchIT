from flask import Flask, request
from flask_restful import Resource, Api
from json import dumps
from flask_jsonpify import jsonify

app = Flask(__name__)
api = Api(app)

class User(Resource):
    def get(self):
        return {'name' : 'testname'}

api.add_resource(User, '/users')

if __name__ == '__main__':
    app.run(port='5002')
