from flask import Blueprint, request, jsonify
from src.models.note import Note
from src.config.settings import token_required

notes_bp = Blueprint('notes', __name__)

@notes_bp.route('', methods=['POST'])
@token_required
def create_note():
    data = request.get_json()
    note_id = Note.create(
        request.user_id,
        data['title'],
        data['content'],
        data.get('color', '#FFFFFF')
    )
    return jsonify({"id": note_id}), 201

@notes_bp.route('', methods=['GET'])
@token_required
def list_notes():
    notes = Note.get_by_user(request.user_id)
    return jsonify(notes), 200



@notes_bp.route('/<int:note_id>', methods=['PUT'])
@token_required
def update_note(note_id):
    data = request.get_json()
    if Note.update(note_id, request.user_id, data):
        return jsonify({"message": "Nota actualizada"}), 200
    return jsonify({"error": "Nota no encontrada"}), 404

@notes_bp.route('/<int:note_id>', methods=['DELETE'])
@token_required
def delete_note(note_id):
    if Note.delete(note_id, request.user_id):
        return jsonify({"message": "Nota eliminada"}), 200
    return jsonify({"error": "Nota no encontrada"}), 404

@notes_bp.route('/search', methods=['GET'])
@token_required
def search_notes():
    query = request.args.get('q', '')
    notes = Note.search(request.user_id, query)
    return jsonify(notes), 200