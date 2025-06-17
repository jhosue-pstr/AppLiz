from flask import Blueprint, request, jsonify
from flask_socketio import emit
from src.models.chat import Chat, Message
from src.config.settings import token_required
from src import socketio
import os
from werkzeug.utils import secure_filename
from datetime import datetime

chats_bp = Blueprint('chats', __name__)

# Configuración de uploads (ajusta según tu estructura)
UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), '..', 'static', 'uploads')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'pdf', 'doc', 'docx', 'mp4'}

# Helpers
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# API Routes
@chats_bp.route('/', methods=['GET'])
@token_required
def get_user_chats():
    try:
        chats = Chat.get_user_chats(request.user_id)
        return jsonify({
            "success": True,
            "data": chats,
            "count": len(chats)
        }), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@chats_bp.route('/', methods=['POST'])
@token_required
def create_chat():
    data = request.get_json()
    chat_id = Chat.create(
        name=data.get('name'),
        is_group=data.get('is_group', False),
        theme=data.get('theme'),
        created_by=request.user_id
    )
    
    # Añadir participantes si es grupo
    if data.get('is_group') and 'participants' in data:
        for user_id in data['participants']:
            if user_id != request.user_id:
                Chat.add_participant(chat_id, user_id)
    
    return jsonify({"chat_id": chat_id}), 201

@chats_bp.route('/<int:chat_id>/participants', methods=['POST'])
@token_required
def add_participant(chat_id):
    data = request.get_json()
    Chat.add_participant(chat_id, data['user_id'])
    socketio.emit('participant_added', {
        'chat_id': chat_id,
        'user_id': data['user_id']
    }, room=str(chat_id))
    return jsonify({"success": True}), 200

@chats_bp.route('/<int:chat_id>/messages', methods=['GET'])
@token_required
def get_messages(chat_id):
    before = request.args.get('before', type=int)
    messages = Message.get_by_chat(chat_id, before_message_id=before)
    return jsonify(messages), 200

@chats_bp.route('/<int:chat_id>/messages', methods=['POST'])
@token_required
def send_message(chat_id):
    if 'file' in request.files:
        file = request.files['file']
        if file and allowed_file(file.filename):
            filename = secure_filename(f"{datetime.now().timestamp()}_{file.filename}")
            filepath = os.path.join(UPLOAD_FOLDER, filename)
            file.save(filepath)
            
            file_url = f"/uploads/{filename}"
            message_type = 'image' if file.content_type.startswith('image/') else 'file'
            
            message_id = Message.create(
                chat_id=chat_id,
                user_id=request.user_id,
                content=request.form.get('message', ''),
                message_type=message_type,
                file_url=file_url
            )
            
            socketio.emit('new_message', {
                'chat_id': chat_id,
                'message': {
                    'id': message_id,
                    'content': request.form.get('message', ''),
                    'message_type': message_type,
                    'file_url': file_url,
                    'user_id': request.user_id,
                    'sent_at': datetime.now().isoformat()
                }
            }, room=str(chat_id))
            
            return jsonify({"message_id": message_id}), 201
        else:
            return jsonify({"error": "File type not allowed"}), 400
    else:
        data = request.get_json()
        message_id = Message.create(
            chat_id=chat_id,
            user_id=request.user_id,
            content=data['content']
        )
        
        socketio.emit('new_message', {
            'chat_id': chat_id,
            'message': {
                'id': message_id,
                'content': data['content'],
                'message_type': 'text',
                'user_id': request.user_id,
                'sent_at': datetime.now().isoformat()
            }
        }, room=str(chat_id))
        
        return jsonify({"message_id": message_id}), 201

# WebSocket Events
@socketio.on('join_chat')
def on_join(data):
    chat_id = data['chat_id']
    join_room(str(chat_id))
    emit('status', {'msg': f'User {data["user_id"]} has joined the chat {chat_id}'}, room=str(chat_id))

@socketio.on('leave_chat')
def on_leave(data):
    chat_id = data['chat_id']
    leave_room(str(chat_id))
    emit('status', {'msg': f'User {data["user_id"]} has left the chat {chat_id}'}, room=str(chat_id))

@socketio.on('typing')
def on_typing(data):
    emit('typing', {
        'chat_id': data['chat_id'],
        'user_id': data['user_id'],
        'is_typing': data['is_typing']
    }, room=str(data['chat_id']))

@socketio.on('mark_as_read')
def on_mark_as_read(data):
    Message.mark_as_read(data['message_id'], data['user_id'])
    emit('message_read', {
        'message_id': data['message_id'],
        'chat_id': data['chat_id'],
        'user_id': data['user_id']
    }, room=str(data['chat_id']))