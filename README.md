


# VRV Security - Backend Developer Internship Assignment

## **Introduction**

This project implements an RBAC system using **Flask, JWT for authentication, and MySQL for database management**, ensuring role-based access to resources.

Flask was chosen for its flexibility in building RESTful APIs. Additionally, I developed a **real-time app** with similar RBAC features, used at **Saveetha Medical College** for data collection. [https://apps.apple.com/in/app/orthoflexelbow/id6738036592]

## **AI Integration**

The system can be extended to integrate **AI-driven authentication** and **authorization systems** for intelligent access management. With my experience in AI and cybersecurity, I can contribute by designing intelligent monitoring systems that detect and prevent unauthorized access attempts in real time.

## **Project Overview**



- **Frontend**: Flutter
  - Communicates with the backend for user registration, login, and role-based access.
  - Handles user interactions and displays content based on the user's role.

- **Backend**: Flask
  - Handles requests, authenticates users, and provides access based on roles.

- **Database**: MySQL
  - Stores user details and roles.
  - Follows best practices with foreign keys, cascading deletes, and indexing for fast queries.

## Application Screens

| Screen             | Core Functionality      | Access Control      | Image               |
|--------------------|-------------------------|---------------------|---------------------|
| Login              | User Authentication     | Public Access       | ![Login]([image_url](https://github.com/sai12092003/Assigment/blob/main/Screen_images/screen1.jpeg)) |
| Registration       | User Onboarding         | Public Access       | ![Registration](image_url) |
| Dashboard          | User Overview           | Authenticated Users | ![Dashboard](image_url) |
| Comment Management | Interaction Platform    | Role-Based Access   | ![Comment Management](image_url) |
| Admin Panel        | System Configuration    | Admin Exclusive     | ![Admin Panel](image_url) |
| Profile Management | Personal Information    | Authenticated Users | ![Profile Management](image_url) |
| Role Assignment    | User Permission Control | Admin Exclusive     | ![Role Assignment](image_url) |
| System Settings    | Application Configuration | Role-Dependent      | ![System Settings](image_url) |



### **Key Technologies and Libraries Used**:
- **Flask**: Web framework
- **Flask-SQLAlchemy**: ORM for database interaction
- **Flask-JWT-Extended**: For JSON Web Token authentication
- **Bcrypt**: Password hashing
- **MySQL**: Database for storing user and role data

## **Setup Instructions**

### **Requirements**:
- Python 3.x
- MySQL Server
- Dart (for Flutter development)

  ## Project Structure

```
vrv-security/
│
├── backend/
│   ├── app.py             # Core application logic
│   ├── models.py          # Database schema definitions
│   ├── routes.py          # API endpoint configurations
│   └── requirements.txt   # Dependency management
│
├── frontend/
│   ├── lib/
│   │   ├── screens/       # User interface components
│   │   └── services/      # API interaction layers
│   └── pubspec.yaml       # Flutter dependencies
│
└── README.md              # Project documentation
```

## Setup Instructions

### 1. Database Setup
```sql
CREATE DATABASE vrv_security;
USE vrv_security;

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);
```

### 2. Install Dependencies
```bash
pip install flask flask_sqlalchemy flask_jwt_extended flask_bcrypt pymysql
```

### 3. Configuration
Update the following in `app.py`:
- Database Connection String
```python
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://username:password@localhost/vrv_security'
app.config['SECRET_KEY'] = 'your_secret_key'
```

### 4. Run the Application
```bash
python app.py
```

## API Endpoints

### 1. User Registration
- **Endpoint**: `POST /register`
- **Request Body**:
```json
{
    "email": "user@example.com", 
    "password": "password123",
    "role": "user"
}
```
- **Responses**:
  - `201`: User registered successfully
  - `400`: Email and password required
  - `400`: User already exists

### 2. User Login
- **Endpoint**: `POST /login`
- **Request Body**:
```json
{
    "email": "user@example.com",
    "password": "password123"
}
```
- **Responses**:
  - `200`: Login successful (returns JWT token)
  - `400`: Email and password required
  - `401`: Invalid credentials

### 3. Get User Role
- **Endpoint**: `GET /get_role`
- **Authentication**: JWT Required
- **Responses**:
  - `200`: Returns user role
  - `404`: User not found

### 4. Post Comment
- **Endpoint**: `POST /post_comment`
- **Request Body**:
```json
{
    "comments": "Sample comment",
    "email": "user@example.com"
}
```
- **Responses**:
  - `201`: Comment posted successfully
  - `400`: Missing comment or email
  - `500`: Server error

### 5. Get Comments
- **Endpoint**: `GET /get_comments`
- **Authentication**: JWT Required
- **Response**: List of comments sorted by timestamp

### 6. Delete Comment
- **Endpoint**: `DELETE /delete_comment/<comment_id>`
- **Authentication**: JWT Required (Admin/Moderator only)
- **Responses**:
  - `200`: Comment deleted successfully
  - `403`: Permission denied

### 7. Delete User
- **Endpoint**: `DELETE /delete_user/<user_email>`
- **Authentication**: JWT Required (Admin only)
- **Responses**:
  - `200`: User deleted successfully
  - `403`: Permission denied

### 8. Update User Role
- **Endpoint**: `PUT /update_role`
- **Authentication**: JWT Required (Admin only)
- **Request Body**:
```json
{
    "email": "user@example.com",
    "role": "moderator"
}
```
- **Responses**:
  - `200`: Role updated successfully
  - `400`: Email and role required
  - `403`: Permission denied



## **Database Design**

1. **Users Table**: Stores user details, including the username, email, and hashed password. It is associated with a **Role** via a foreign key.
2. **Roles Table**: Stores available roles such as `Admin`, `User`, `Moderator`, etc.
3. **Foreign Key Constraints**: Ensures data integrity and that the roles are properly linked to users.
4. **Cascading Deletes**: Ensures that if a role is deleted, all users associated with that role are also deleted.

---


## **Security Best Practices**

### **Password Hashing**  
We use the **bcrypt** library to hash user passwords before storing them in the database. This ensures that even if the database is compromised, the passwords remain secure.

- **Hashing process**:
    
    password = request.json.get('password')
    hashed_password = hashpw(password.encode('utf-8'), gensalt())
    
- During login, we verify the password using:
    ```python
    if checkpw(password.encode('utf-8'), stored_password.encode('utf-8')):
        # Authentication successful
    ```

### **JWT Authentication**
JWTs are used to authenticate users and provide secure access to protected routes. Upon successful login, a JWT token is generated with a payload containing the user’s identity and role.

```python
access_token = create_access_token(identity=user.id)
```

### **Role-Based Access Control (RBAC)**
RBAC is implemented to ensure that only users with specific roles can access certain endpoints. For example:
- Admins can access all routes.
- Regular users can only access user-specific routes.
- Unauthorized access is blocked.

---

## **Conclusion**

This backend system provides a secure, scalable solution for implementing Role-Based Access Control (RBAC) in a web application. The use of **Flask**, **MySQL**, and **JWT** ensures that the system is efficient, secure, and easy to extend. The project adheres to best practices in security, including **password hashing**, **JWT authentication**, and **role-based authorization**. By following this implementation, we can ensure that only authorized users can access sensitive data and perform critical actions.

---







## Performance Optimization

- Efficient database queries
- Minimal overhead authentication
- Optimized token management
- Scalable request handling




