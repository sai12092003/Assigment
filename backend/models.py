from app import db
from datetime import datetime

# User Model
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)
    role = db.Column(db.String(50), nullable=False, default='user')  # 'user' is the default role

    def __init__(self, email, password, role='user'):
        self.email = email
        self.password = password
        self.role = role


# Comment Model
class Comment(db.Model):
    __tablename__ = 'comment'  # Ensure this matches your database table name
    id = db.Column(db.Integer, primary_key=True)
    comment = db.Column(db.String(200), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"Comment({self.comment}, {self.email})"
