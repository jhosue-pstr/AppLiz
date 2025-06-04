from src.config.database import Database

class Period:
    @staticmethod
    def close_period(user_id, period_name, description=None):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            # Verificar si el usuario tiene permisos para cerrar periodos
            cursor.execute(
                "SELECT is_admin FROM users WHERE id = %s",
                (user_id,)
            )
            user = cursor.fetchone()
            
            if not user or not user['is_admin']:
                return False

            # Cerrar el periodo
            cursor.execute(
                """INSERT INTO closed_periods 
                (user_id, period_name, description) 
                VALUES (%s, %s, %s)""",
                (user_id, period_name, description)
            )
            connection.commit()
            return True
        finally:
            Database.close_connection(connection, cursor)

    @staticmethod
    def get_closed_periods():
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """SELECT cp.id, u.username, cp.period_name, cp.description, cp.closed_at 
                FROM closed_periods cp
                JOIN users u ON cp.user_id = u.id
                ORDER BY cp.closed_at DESC"""
            )
            return cursor.fetchall()
        finally:
            Database.close_connection(connection, cursor)