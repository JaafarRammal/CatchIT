from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from config import Config
import json

app = Flask(__name__)
app.config.from_object(Config)

db = SQLAlchemy(app)
ma = Marshmallow(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=True, nullable=False)
    points_collected = db.Column(db.Integer, default=0)

    def __init__(self, name, points_collected):
        self.name = name
        self.points_collected = points_collected

class UserSchema(ma.Schema):
    class Meta:
        fields = ('id', 'name', 'points_collected')

user_schema = UserSchema()
users_schema = UserSchema(many=True)

@app.route('/user', methods=['POST'])
def add_user():
    name = request.json['name']
    points_collected = request.json['points_collected']

    new_user = User(name, points_collected)

    db.session.add(new_user)
    db.session.commit()

    return user_schema.jsonify(new_user)


# Get n Users
@app.route('/users', methods=['GET'])
def get_all_users():
    all_users = User.query.all()
    result = users_schema.dump(all_users)
    return json.dumps(result)

# Get n Users
@app.route('/users/<n>', methods=['GET'])
def get_top_users(n):
    top_n_users = User.query.order_by(User.points_collected.desc()).limit(n)
    result = users_schema.dump(top_n_users)
    return json.dumps(result)

# Get a User
@app.route('/user/<id>', methods=['GET'])
def get_user(id):
    user = User.query.get(id)
    return user_schema.jsonify(user)

# Update a User
@app.route('/user/<id>', methods=['PUT'])
def update_user(id):
    user = User.query.get(id)
    name = request.json['name']
    points_collected = request.json['points_collected']

    user.name = name
    user.points_collected = points_collected

    db.session.commit()
    
    return user_schema.jsonify(user)

# Delete a User
@app.route('/user/<id>', methods=['DELETE'])
def delete_user(id):
    user = User.query.get(id)
    db.session.delete(user)
    db.session.commit()

    return user_schema.jsonify(user)

if __name__ == '__main__':
    app.run(port='5002')
