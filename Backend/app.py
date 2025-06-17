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
from src.routes.chat import chats_bp  # Blueprint del chat
from flask_socketio import SocketIO

# Configuración de la aplicación Flask
app = Flask(__name__)
app.config['SECRET_KEY'] = 'tu_clave_secreta'
app.config['UPLOAD_FOLDER'] = os.path.join(os.path.dirname(__file__), 'static', 'uploads')
app.config['JWT_SECRET_KEY'] = '1'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(minutes=1440)

# Configuración de SocketIO con async_mode
socketio = SocketIO(app, 
                   cors_allowed_origins="*",
                   async_mode='eventlet')  # Usar eventlet para mejor rendimiento

# Decorador para verificación de token
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"error": "Token faltante"}), 401
        
        try:
            data = jwt.decode(token.split()[1], app.config['JWT_SECRET_KEY'], algorithms=['HS256'])
            request.user_id = data['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({"error": "Token expirado"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"error": "Token inválido"}), 401
        
        return f(*args, **kwargs)
    return decorated

# Configuración CORS mejorada
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With')
    response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS')
    response.headers.add('Access-Control-Allow-Credentials', 'true')
    return response

# Importar y registrar blueprints
from src.routes.auth import auth_bp

# Registrar todos los blueprints
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(users_bp, url_prefix='/api/users')
app.register_blueprint(emotion_bp, url_prefix='/api/emotion')
app.register_blueprint(notes_bp, url_prefix='/api/notes')
app.register_blueprint(tasks_bp, url_prefix='/api/tasks')
app.register_blueprint(events_bp, url_prefix='/api/events')
app.register_blueprint(period_bp, url_prefix='/api/period')
app.register_blueprint(contacts_bp, url_prefix='/api/emergency-contacts')
app.register_blueprint(resources_bp, url_prefix='/api/resources')
app.register_blueprint(chats_bp, url_prefix='/api/chats')  # Registrar blueprint de chats

# Ruta de prueba mejorada
@app.route('/')
def home():
    return jsonify({
        "message": "¡Bienvenido a Uni-Pulse API!",
        "status": "operativo",
        "version": "1.0",
        "endpoints": {
            "auth": "/api/auth",
            "users": "/api/users",
            "chats": "/api/chats",
            "emotions": "/api/emotion",
            "notes": "/api/notes",
            "tasks": "/api/tasks",
            "events": "/api/events",
            "periods": "/api/period",
            "contacts": "/api/emergency-contacts",
            "resources": "/api/resources"
        }
    })

# Manejo de errores global mejorado
@app.errorhandler(400)
def bad_request(error):
    return jsonify({"error": "Solicitud incorrecta", "details": str(error)}), 400

@app.errorhandler(401)
def unauthorized(error):
    return jsonify({"error": "No autorizado"}), 401

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Endpoint no encontrado"}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Error interno del servidor"}), 500

# Punto de entrada principal mejorado
if __name__ == '__main__':
    # Crear carpeta de uploads si no existe
    if not os.path.exists(app.config['UPLOAD_FOLDER']):
        os.makedirs(app.config['UPLOAD_FOLDER'])
    
    # Iniciar servidor con SocketIO
    socketio.run(
        app,
        host='0.0.0.0',
        port=5000,
        debug=True,
        use_reloader=True,
        log_output=True
    )