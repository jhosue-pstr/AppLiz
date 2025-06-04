from src.config.database import Database

class Chat:
    @staticmethod
    def create(name, is_group=False, theme=None):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """INSERT INTO chats (name, is_group, theme) 
                VALUES (%s, %s, %s)""",
                (name, is_group, theme)
            )
            connection.commit()
            return cursor.lastrowid
        finally:
            Database.close_connection(connection, cursor)

    @staticmethod
    def add_participant(chat_id, user_id):
        connection = Database.get_connection()
        cursor = connection.cursor()
        try:
            cursor.execute(
                """INSERT INTO chat_participants (chat_id, user_id) 
                VALUES (%s, %s)""",
                (chat_id, user_id)
            )
            connection.commit()
        finally:
            Database.close_connection(connection, cursor)

class Message:
    @staticmethod
    def create(chat_id, user_id, content):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """INSERT INTO messages (chat_id, user_id, content) 
                VALUES (%s, %s, %s)""",
                (chat_id, user_id, content)
            )
            connection.commit()
            return cursor.lastrowid
        finally:
            Database.close_connection(connection, cursor)

    @staticmethod
    def get_by_chat(chat_id, limit=100):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """SELECT * FROM messages 
                WHERE chat_id = %s 
                ORDER BY sent_at DESC 
                LIMIT %s""",
                (chat_id, limit)
            )
            return cursor.fetchall()
        finally:
            Database.close_connection(connection, cursor)