from flask import Blueprint, request, jsonify
from src.config.database import Database
import jwt
import bcrypt
import os
from datetime import datetime, timedelta
import mysql.connector
from src.models.points import PointSystem



auth_bp = Blueprint('auth', __name__)
JWT_SECRET = "1"
JWT_EXPIRATION = timedelta(hours=24)

@auth_bp.route('/register', methods=['POST'])
def register():
    connection = Database.get_connection()
    cursor = connection.cursor(dictionary=True)
    
    try:
        data = request.get_json()
        email = data['email']
        password = data['password']
        name = data['name']
        lastname_paternal = data['lastname_paternal']

        cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
        if cursor.fetchone():
            return jsonify({"error": "El email ya está registrado"}), 400

        hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

        query = """
            INSERT INTO users 
            (email, password_hash, name, lastname_paternal, created_at)
            VALUES (%s, %s, %s, %s, NOW())
        """
        cursor.execute(query, (email, hashed_password, name, lastname_paternal))
        connection.commit()

        user_id = cursor.lastrowid
        token = jwt.encode({
            'user_id': user_id,
            'exp': datetime.utcnow() + JWT_EXPIRATION
        }, JWT_SECRET, algorithm='HS256')

        return jsonify({"token": token, "user_id": user_id}), 201

    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500
    finally:
        Database.close_connection(connection, cursor)




@auth_bp.route('/login', methods=['POST'])
def login():
    connection = Database.get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        data = request.get_json()
        email = data['email']
        password = data['password']

        cursor.execute("SELECT id, password_hash FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()
        if not user:
            return jsonify({"error": "Credenciales inválidas"}), 401

        if not bcrypt.checkpw(password.encode('utf-8'), user['password_hash'].encode('utf-8')):
            return jsonify({"error": "Credenciales inválidas"}), 401

        token = jwt.encode({
            'user_id': user['id'],
            'exp': datetime.utcnow() + JWT_EXPIRATION
        }, JWT_SECRET, algorithm='HS256')

        # Dar monedas diarias (si no las ha recibido hoy)
        PointSystem.add_daily_coins(user['id'])

        return jsonify({"token": token, "user_id": user['id'], "message": "¡Bienvenido! +3 monedas"}), 200

    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500

    finally:
        Database.close_connection(connection, cursor)