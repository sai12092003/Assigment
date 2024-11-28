from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_jwt_extended import JWTManager
import pymysql
from datetime import datetime

# Install pymysql as MySQLdb
pymysql.install_as_MySQLdb()

# Initialize Flask app
app = Flask(__name__)

# Configurations for the database and JWT secret key
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://SAIII12:120903@192.168.1.6/vrv'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = 'your_secret_key'

# Initialize extensions
db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
jwt = JWTManager(app)

# Import routes after app initialization to avoid circular imports
from routes import *

# Create all tables if they do not exist
with app.app_context():
    db.create_all()

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
