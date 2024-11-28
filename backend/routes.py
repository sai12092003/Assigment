from app import app, db, bcrypt, jwt
from flask import request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token
from models import User, Comment
from sqlalchemy import text

# Route to register a new user
@app.route('/register', methods=['POST'])
def register():
    email = request.json.get('email', None)
    password = request.json.get('password', None)
    role = request.json.get('role', 'user')  # Default to 'user' if no role is provided

    if not email or not password:
        return jsonify({"msg": "Email and password are required"}), 400

    # Check if user already exists
    user = User.query.filter_by(email=email).first()
    if user:
        return jsonify({"msg": "User already exists"}), 400

    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')
    new_user = User(email=email, password=hashed_password, role=role)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"msg": "User registered successfully"}), 201


# Route to login and get an access token
@app.route('/login', methods=['POST'])
def login():
    email = request.json.get('email', None)
    password = request.json.get('password', None)

    if not email or not password:
        return jsonify({"msg": "Email and password are required"}), 400

    user = User.query.filter_by(email=email).first()
    if not user or not bcrypt.check_password_hash(user.password, password):
        return jsonify({"msg": "Invalid credentials"}), 401

    access_token = create_access_token(identity=email)
    return jsonify(access_token=access_token), 200


@app.route('/get_role', methods=['GET'])
@jwt_required()
def get_role():
    current_user = get_jwt_identity()
    user = User.query.filter_by(email=current_user).first()

    if not user:
        return jsonify({"msg": "User not found"}), 404

    return jsonify({"role": user.role}), 200


@app.route('/post_comment', methods=['POST'])
def post_comment():
    try:
        data = request.get_json()
        comment_text = data.get('comments')
        user_email = data.get('email')

        if not comment_text or not user_email:
            return jsonify({'message': 'Comment text and email are required'}), 400

        new_comment = Comment(comment=comment_text, email=user_email)
        db.session.add(new_comment)
        db.session.commit()

        return jsonify({'message': 'Comment posted successfully', 'comment': new_comment.comment, 'email': new_comment.email}), 201
    except Exception as e:
        return jsonify({'message': 'An error occurred while posting the comment', 'error': str(e)}), 500


@app.route('/get_comments', methods=['GET'])
@jwt_required()
def get_comments():
    query = text("SELECT id, comment, email, timestamp FROM comment ORDER BY timestamp DESC")
    comments = db.session.execute(query).fetchall()
    
    result = [dict(row._mapping) for row in comments]
    
    return jsonify({'comments': result}), 200


@app.route('/delete_comment/<int:comment_id>', methods=['DELETE'])
@jwt_required()
def delete_comment(comment_id):
    current_user = get_jwt_identity()
    role = db.session.execute(
        text("SELECT role FROM user WHERE email = :email"),
        {'email': current_user}
    ).fetchone()

    if role and role[0] in ['admin', 'moderator']:
        db.session.execute(
            text("DELETE FROM comment WHERE id = :id"),
            {'id': comment_id}
        )
        db.session.commit()

        return jsonify({'msg': 'Comment deleted successfully'}), 200

    return jsonify({'msg': 'Permission denied'}), 403


@app.route('/delete_user/<string:user_email>', methods=['DELETE'])
@jwt_required()
def delete_user(user_email):
    current_user = get_jwt_identity()
    role = db.session.execute("SELECT role FROM Users WHERE email = :email", {'email': current_user}).fetchone()

    if role and role[0] == 'admin':
        db.session.execute("DELETE FROM Users WHERE email = :email", {'email': user_email})
        db.session.commit()
        return jsonify({'msg': f'User {user_email} deleted successfully'}), 200

    return jsonify({'msg': 'Permission denied'}), 403


@app.route('/update_role', methods=['PUT'])
@jwt_required()
def update_role():
    current_user = get_jwt_identity()
    role = db.session.execute("SELECT role FROM Users WHERE email = :email", {'email': current_user}).fetchone()

    if role and role[0] == 'admin':
        data = request.json
        user_email = data.get('email')
        new_role = data.get('role')

        if not user_email or not new_role:
            return jsonify({'msg': 'Email and role are required'}), 400

        db.session.execute(
            "UPDATE Users SET role = :role WHERE email = :email",
            {'role': new_role, 'email': user_email}
        )
        db.session.commit()
        return jsonify({'msg': f'Role for {user_email} updated to {new_role}'}), 200

    return jsonify({'msg': 'Permission denied'}), 403


@app.route('/get_comment/<int:comment_id>', methods=['GET'])
@jwt_required()
def get_comment(comment_id):
    comment = db.session.execute(
        "SELECT id, comments, email, time_posted FROM PostComments WHERE id = :id",
        {'id': comment_id}
    ).fetchone()

    if comment:
        return jsonify(dict(comment)), 200
    return jsonify({'msg': 'Comment not found'}), 404


@app.route('/get_users', methods=['GET'])
@jwt_required()
def get_users():
    current_user = get_jwt_identity()
    users = User.query.all()
    emails = [user.email for user in users]

    return jsonify({"users": emails, "current_user": current_user}), 200
