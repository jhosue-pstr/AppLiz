from flask import Blueprint, request, jsonify
from src.config.settings import token_required
from src.models.EmotionDiary import EmotionDiary
emotion_bp = Blueprint('emotion', __name__)

@emotion_bp.route('/log', methods=['POST'])
@token_required
def log_emotion():
    data = request.get_json()
    required = ['emotion', 'intensity', 'content']
    if not all(field in data for field in required):
        return jsonify({"error": "Faltan campos requeridos"}), 400

    try:
        entry_id = EmotionDiary.log_emotion(
            request.user_id,
            data['emotion'],
            data['intensity'],
            data['content'],
            data.get('tags')
        )
        return jsonify({"id": entry_id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@emotion_bp.route('/history', methods=['GET'])
@token_required
def get_history():
    days = request.args.get('days', default=30, type=int)
    history = EmotionDiary.get_emotional_history(request.user_id, days)
    return jsonify(history), 200

@emotion_bp.route('/stats', methods=['GET'])
@token_required
def get_stats():
    stats = EmotionDiary.get_emotional_stats(request.user_id)
    return jsonify({
        "weekly_avg": sum(day['avg_intensity'] for day in stats[:7]) / 7,
        "emotion_distribution": {
            "happy": sum(1 for day in stats if day['emotion'] == 'happy'),
            "neutral": sum(1 for day in stats if day['emotion'] == 'neutral'),
            "sad": sum(1 for day in stats if day['emotion'] == 'sad')
        }
    }), 200

@emotion_bp.route('/patterns', methods=['GET'])
@token_required
def get_patterns():
    try:
        patterns = EmotionDiary.detect_patterns(request.user_id)
        return jsonify(patterns), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500