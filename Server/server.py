from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from sqlalchemy import func
from config import Config
import json

app = Flask(__name__)
app.config.from_object(Config)

db = SQLAlchemy(app)
ma = Marshmallow(app)

# USER API CALLS

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=True, nullable=False)
    points_collected = db.Column(db.Integer, default=0)
    location = db.Column(db.String(80))
    transactions = db.relationship('Transaction', backref='user', lazy=True)

    def __init__(self, name, points_collected, location):
        self.name = name
        self.points_collected = points_collected
        self.location = location

class UserSchema(ma.Schema):
    class Meta:
        fields = ('id', 'name', 'points_collected', 'location')

user_schema = UserSchema()
users_schema = UserSchema(many=True)

@app.route('/user', methods=['POST'])
def add_user():
    name = request.json['name']
    points_collected = request.json['points_collected']
    location = request.json['location']

    new_user = User(name, points_collected, location)

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
@app.route('/users/<n>/<location>', methods=['GET'])
def get_top_users(n, location):
    top_n_users = User.query.filter(User.location == location).order_by(User.points_collected.desc()).limit(n)
    result = users_schema.dump(top_n_users)
    return json.dumps(result)

# Get a User
@app.route('/user/<id>', methods=['GET'])
def get_user(id):
    user = User.query.get(id)
    return user_schema.jsonify(user)

# Get a user's remaining points to spend
@app.route('/user/points_available/<id>', methods=['GET'])
def get_available_points(id):
    sum_of_points = db.session.query(func.sum(Transaction.points).label('points')).filter(Transaction.user_id == id).scalar()
    return '{ "points_available" : ' + str(sum_of_points) + '}'

# Get a user's position on the leaderboard
@app.route('/user/<id>/position', methods=['GET'])
def get_user_position(id):
    user = User.query.get(id)
    q = db.session.query(User).filter(User.location == user.location).filter(User.points_collected > user.points_collected)

    higher_user_count = q.statement.with_only_columns([func.count()]).order_by(None)
    user_position = q.session.execute(higher_user_count).scalar() + 1

    return '{ "user_position" : ' + str(user_position) + '}'

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

# TRANSACTION API CALLS

class Transaction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    #user_id = db.Column(db.Integer)
    points = db.Column(db.Integer)
    label = db.Column(db.String(80))
    datetime = db.Column(db.Integer)
    location = db.Column(db.String(80))
    
    def __init__(self, user_id, points, label, datetime, location):
        self.user_id = user_id
        self.points = points
        self.label = label
        self.datetime = datetime
        self.location = location

class TransactionSchema(ma.Schema):
    class Meta:
        fields = ('id', 'user_id', 'points', 'label', 'datetime', 'location')

transaction_schema = TransactionSchema()
transactions_schema = TransactionSchema(many=True)

@app.route('/transaction', methods=['POST'])
def add_transaction():
    user_id = request.json['user_id']
    points = request.json['points']
    label = request.json['label']
    datetime = request.json['datetime']
    location = request.json['location']

    new_transaction = Transaction(user_id, points, label, datetime, location)

    new_user = User.query.get(user_id)
    if points > 0:
        new_user.points_collected = new_user.points_collected + points 
    new_user.location = location

    db.session.add(new_transaction)
    db.session.commit()

    return transaction_schema.jsonify(new_transaction)

@app.route('/transaction/<user_id>/<n>', methods=['GET'])
def get_transaction(user_id, n):
    transactions = Transaction.query.filter(Transaction.user_id == user_id).order_by(Transaction.datetime.desc()).limit(n)
    result = transactions_schema.dump(transactions)
    return json.dumps(result)

# ITEM API CALLS

class Item(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    label = db.Column(db.String(80), unique=True, nullable=False)
    points = db.Column(db.Integer)
    def __init__(self, label, points):
        self.label = label
        self.points = points

class ItemSchema(ma.Schema):
    class Meta:
        fields = ('id','label','points')

item_schema = ItemSchema()
items_schema = ItemSchema(many=True)

# Create a new Item
@app.route('/item', methods=['POST'])
def add_item():
    label = request.json['label']
    points = request.json['points']

    new_item = Item(label, points)

    db.session.add(new_item)
    db.session.commit()
    
    return item_schema.jsonify(new_item)

# Get all Items
@app.route('/items', methods=['GET'])
def get_items():
    all_items = Item.query.all()
    result = items_schema.dump(all_items)

    return json.dumps(result)

# Get single Item
@app.route('/item/<id>', methods=['GET'])
def get_item(id):
    item = Item.query.get(id)
    return item_schema.jsonify(item)

# Get the points value of a single item
@app.route('/item/<label>', methods=['GET'])
def get_item_points(label):
    item = Item.query.filter(Item.label == label).first()
    return item_schema.jsonify(item.points)

# Update an Item
@app.route('/item/<id>', methods=['PUT'])
def update_product(id):
    item = Item.query.get(id)

    label = request.json['label']
    points = request.json['points']

    item.label = label
    item.points = points

    db.session.commit()

    return item_schema.jsonify(item)

# Delete Item
@app.route('/item/<id>', methods=['DELETE'])
def delete_product(id):
    item = Item.query.get(id)
    db.session.delete(item)
    db.session.commit()

    return item_schema.jsonify(item)

if __name__ == '__main__':
    app.run(port='5002')
