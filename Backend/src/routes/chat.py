from flask import Blueprint, request, jsonify
from src.models.chat import Chat, Message
from src.config.settings import token_required

chats_bp = Blueprint('chats', __name__)

@chats_bp.route('/create', methods=['POST'])
@token_required
def create_chat():
    data = request.get_json()
    chat_id = Chat.create(
        name=data.get('name'),
        is_group=data.get('is_group', False),
        theme=data.get('theme')
    )
    Chat.add_participant(chat_id, request.user_id)
    return jsonify({"chat_id": chat_id}), 201

@chats_bp.route('/<int:chat_id>/messages', methods=['GET'])
@token_required
def get_messages(chat_id):
    messages = Message.get_by_chat(chat_id)
    return jsonify(messages), 200

