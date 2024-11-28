


# VRV Security - Backend Developer Internship Assignment

## **Introduction**

This project aims to implement a robust **Role-Based Access Control (RBAC)** system using **Flask** as the backend framework, with **JWT** for authentication and **MySQL** for database management. This system is designed to ensure that users have appropriate access to resources based on their assigned roles (Admin, User, Moderator, etc.).

I chose **Flask** for this project because it is lightweight, flexible, and well-suited for building RESTful APIs. With its powerful extension system, including **Flask-SQLAlchemy** for database interaction and **Flask-JWT-Extended** for secure JWT-based authentication, Flask ensures quick and efficient implementation.

## **AI Integration**

The system can be extended to integrate **AI-driven authentication** and **authorization systems** for intelligent access management. With my experience in AI and cybersecurity, I can contribute by designing intelligent monitoring systems that detect and prevent unauthorized access attempts in real time.

## **Project Overview**

### **Frontend**: Flutter  
The Flutter app communicates with the backend to provide the user interface, enabling user registration, login, and role-based access. The front end handles user interactions, such as sending requests to the backend and displaying the relevant content based on the user’s role.

### **Backend**: Flask  
The backend is built with Flask and is responsible for handling requests, authenticating users, checking permissions, and providing access to specific resources based on roles.

### **Database**: MySQL  
We use MySQL to store user details and roles. The database schema follows best practices, including the use of foreign keys, cascading deletes, and indexing for fast queries.

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
- Node.js (for Flutter development)

### **Step 1: Set up the Database**
1. Create a MySQL database.
2. Run the following SQL script to create necessary tables:


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


### **Step 2: Install Dependencies**  
Install the required Python libraries using pip:


pip install flask flask_sqlalchemy flask_jwt_extended bcrypt


### **Step 3: Configure the Backend**
1. Set your MySQL username, password, and database name in the **app.py** file under the following line:


app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://username:password@localhost/vrv_security'


2. Set your JWT secret key:


app.config['JWT_SECRET_KEY'] = 'your_secret_key'


### **Step 4: Run the Flask App**
After setting up the database and configuring the app, run the Flask server:


python app.py


The server will be running on `http://127.0.0.1:5000`.

---

## **API Endpoints**

### **1. User Registration**
- **POST /api/register**
- Request Body:
    
    {
        "username": "exampleuser",
        "email": "user@example.com",
        "password": "password123",
        "role": "Admin"
    }
    
- Response:
    
    {
        "message": "User registered successfully"
    }
    

### **2. User Login**
- **POST /api/login**
- Request Body:
    
    {
        "email": "user@example.com",
        "password": "password123"
    }
    
- Response:

    {
        "access_token": "jwt_token_here"
    }
    

### **3. Protected Route**
- **GET /api/protected**
- This endpoint is protected and can only be accessed by authenticated users with the `User` or `Admin` role.
- Request Header:
    
    Authorization: Bearer <JWT Token>
    
- Response:
    
    {
        "message": "Access granted"
    }
    

---

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

## **Future Enhancements**

- Integration of **AI-driven access control** to monitor and predict unauthorized access attempts in real-time.
- **Multi-Factor Authentication (MFA)** can be implemented for an added layer of security.
- **User Activity Logging**: Implement logging of user activity for auditing purposes.

---


