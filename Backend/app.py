from flask import Flask, request, jsonify
from functools import wraps
import jwt
from datetime import datetime, timedelta
import os
from src.config.database import Database
from src.config.settings import token_required  
from src.routes.users import users_bp
from src.routes.emotion_diary import emotion_bp 
from src.routes.notes import notes_bp
from src.routes.tasks import tasks_bp
from src.routes.events import events_bp
from src.routes.periods import period_bp
from src.routes.emergency_contacts import contacts_bp
from src.routes.resources import resources_bp
from flask_socketio import SocketIO
from src.config.database import Database 


app = Flask(__name__)

app.config['SECRET_KEY'] = 'tu_clave_secreta'
socketio = SocketIO(app, cors_allowed_origins="*")

JWT_SECRET = "1" 
JWT_EXPIRE_MINUTES = 1440 

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"error": "Token faltante"}), 401
        
        try:
            data = jwt.decode(token.split()[1], JWT_SECRET, algorithms=['HS256'])
            request.user_id = data['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({"error": "Token expirado"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"error": "Token inválido"}), 401
        
        return f(*args, **kwargs)
    return decorated

@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE')
    return response

from src.routes.auth import auth_bp
from src.routes.diary import diary_bp

app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(diary_bp, url_prefix='/api/diary')
app.register_blueprint(users_bp, url_prefix='/api/users')
app.register_blueprint(emotion_bp, url_prefix='/api/emotion')
app.register_blueprint(notes_bp, url_prefix='/api/notes')
app.register_blueprint(tasks_bp, url_prefix='/api/tasks')
app.register_blueprint(events_bp, url_prefix='/api/events')
app.register_blueprint(period_bp, url_prefix='/api/period')
app.register_blueprint(contacts_bp, url_prefix='/api/emergency-contacts')
app.register_blueprint(resources_bp, url_prefix='/api/resources')


@app.route('/')
def home():
    return "¡Bienvenido a Uni-Pulse API!"





if __name__ == '__main__':
    app.run(debug=True)