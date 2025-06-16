from src.config.database import Database
from datetime import datetime, timedelta
import json 



class EmotionDiary:
    @staticmethod
    def log_emotion(user_id, emotion, intensity, content, tags=None):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            tags_json = json.dumps(tags, ensure_ascii=False) if tags else None
        
            cursor.execute(
                """INSERT INTO diary_entries 
                (user_id, emotion, intensity, content, tags, created_at)
                VALUES (%s, %s, %s, %s, %s, NOW())""",
                (user_id, emotion, intensity, content, tags_json)  
            )
            connection.commit()
            return cursor.lastrowid
        except Exception as e:
            connection.rollback()
            raise e
        finally:
            Database.close_connection(connection, cursor)





    @staticmethod
    def get_emotional_history(user_id, days=30):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """SELECT 
                    id,
                    emotion, 
                    intensity,
                    content,
                    tags,
                    DATE_FORMAT(created_at, '%Y-%m-%d') as formatted_date
                FROM diary_entries 
                WHERE user_id = %s AND created_at >= %s
                ORDER BY created_at DESC""",
                (user_id, datetime.now() - timedelta(days=days)))
            return cursor.fetchall()
        finally:
            Database.close_connection(connection, cursor)

    @staticmethod
    def get_emotional_stats(user_id):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """SELECT 
                    emotion,  # ¡Añade este campo!
                    AVG(intensity) as avg_intensity,
                    DATE_FORMAT(created_at, '%Y-%m-%d') as date
                FROM diary_entries
                WHERE user_id = %s
                GROUP BY date, emotion""",  # Agrupa también por emoción
                (user_id,)
            )
            return cursor.fetchall()
        finally:
            Database.close_connection(connection, cursor)



    @staticmethod
    def get_weekly_summary(user_id):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """SELECT 
                    DAYNAME(created_at) as day,
                    emotion,
                    COUNT(*) as count,
                    AVG(intensity) as avg_intensity
                FROM diary_entries
                WHERE user_id = %s AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
                GROUP BY day, emotion
                ORDER BY DAYOFWEEK(created_at)""",
                (user_id,))
            return cursor.fetchall()
        finally:
            Database.close_connection(connection, cursor)

    @staticmethod
    def detect_patterns(user_id):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """SELECT 
                    DAYNAME(created_at) as day,
                    emotion,
                    COUNT(*) as count
                FROM diary_entries
                WHERE user_id = %s
                GROUP BY day, emotion
                ORDER BY count DESC""",
                (user_id,)
            )
            results = cursor.fetchall()
        
            return {
                "most_frequent_day": results[0]['day'] if results else None,
                "dominant_emotion": results[0]['emotion'] if results else None
            }
        finally:
            Database.close_connection(connection, cursor)    




