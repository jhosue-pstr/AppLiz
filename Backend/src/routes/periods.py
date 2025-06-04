from flask import Blueprint, request, jsonify
from src.models.period import Period
from src.config.settings import token_required

period_bp = Blueprint('period', __name__)

@period_bp.route('/close', methods=['POST'])
@token_required
def close_period():
    data = request.get_json()
    if Period.close_period(request.user_id, data['period_name'], data.get('description')):
        return jsonify({"message": "Periodo cerrado exitosamente"}), 200
    return jsonify({"error": "No se pudo cerrar el periodo"}), 400

@period_bp.route('/history', methods=['GET'])
@token_required
def get_period_history():
    periods = Period.get_closed_periods()
    return jsonify(periods), 200