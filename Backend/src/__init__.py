from flask_socketio import SocketIO

socketio = SocketIO(async_mode='eventlet')  # Mejor rendimiento para producción