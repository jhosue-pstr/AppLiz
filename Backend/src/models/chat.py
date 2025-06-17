from src.config.database import Database
from datetime import datetime

class Chat:
    @staticmethod
    def create(name, is_group=False, theme=None, created_by=None):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """INSERT INTO chats 
                (name, is_group, theme, created_by, created_at, last_message_at) 
                VALUES (%s, %s, %s, %s, NOW(), NOW())""",
                (name, is_group, theme, created_by)
            )
            connection.commit()
            chat_id = cursor.lastrowid
            if created_by:
                Chat.add_participant(chat_id, created_by, is_admin=True)
            return chat_id
        finally:
            Database.close_connection(connection, cursor)

    @staticmethod
    def add_participant(chat_id, user_id, is_admin=False):
        connection = Database.get_connection()
        cursor = connection.cursor()
        try:
            cursor.execute(
                """INSERT INTO chat_participants 
                (chat_id, user_id, is_admin, joined_at) 
                VALUES (%s, %s, %s, NOW())
                ON DUPLICATE KEY UPDATE left_at = NULL""",
                (chat_id, user_id, is_admin)
            )
            connection.commit()
        finally:
            Database.close_connection(connection, cursor)

    @staticmethod
    def get_user_chats(user_id):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """SELECT 
                    c.id,
                    c.name,
                    c.is_group,
                    c.theme,
                    c.last_message_at,
                    (SELECT COUNT(*) FROM messages m 
                     WHERE m.chat_id = c.id AND m.read_at IS NULL AND m.user_id != %s) as unread_count,
                    (SELECT content FROM messages 
                     WHERE chat_id = c.id ORDER BY sent_at DESC LIMIT 1) as last_message_content,
                    (SELECT u.name FROM messages 
                     JOIN users u ON messages.user_id = u.id 
                     WHERE chat_id = c.id ORDER BY sent_at DESC LIMIT 1) as last_message_sender
                FROM chats c
                JOIN chat_participants cp ON c.id = cp.chat_id
                WHERE cp.user_id = %s AND cp.left_at IS NULL
                ORDER BY c.last_message_at DESC""",
                (user_id, user_id)
            )
            return cursor.fetchall()
        finally:
            Database.close_connection(connection, cursor)

    @staticmethod
    def get_participants(chat_id):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """SELECT u.id, u.name, u.avatar_url, cp.is_admin, cp.joined_at
                FROM users u
                JOIN chat_participants cp ON u.id = cp.user_id
                WHERE cp.chat_id = %s AND cp.left_at IS NULL""",
                (chat_id,)
            )
            return cursor.fetchall()
        finally:
            Database.close_connection(connection, cursor)


class Message:
    @staticmethod
    def create(chat_id, user_id, content, message_type='text', file_url=None):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """INSERT INTO messages 
                (chat_id, user_id, content, message_type, file_url, sent_at) 
                VALUES (%s, %s, %s, %s, %s, NOW())""",
                (chat_id, user_id, content, message_type, file_url)
            )
            
            cursor.execute(
                """UPDATE chats 
                SET last_message_at = NOW() 
                WHERE id = %s""",
                (chat_id,)
            )
            
            connection.commit()
            return cursor.lastrowid
        finally:
            Database.close_connection(connection, cursor)

    @staticmethod
    def get_by_chat(chat_id, limit=100, before_message_id=None):
        connection = Database.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            query = """SELECT m.*, u.name as user_name, u.avatar_url
                      FROM messages m
                      JOIN users u ON m.user_id = u.id
                      WHERE m.chat_id = %s AND m.deleted_at IS NULL"""
            
            params = [chat_id]
            
            if before_message_id:
                query += " AND m.id < %s"
                params.append(before_message_id)
            
            query += " ORDER BY m.sent_at DESC LIMIT %s"
            params.append(limit)
            
            cursor.execute(query, params)
            return cursor.fetchall()
        finally:
            Database.close_connection(connection, cursor)

    @staticmethod
    def mark_as_read(message_id, user_id):
        connection = Database.get_connection()
        cursor = connection.cursor()
        try:
            cursor.execute(
                """UPDATE messages 
                SET read_at = NOW() 
                WHERE id = %s AND user_id != %s AND read_at IS NULL""",
                (message_id, user_id)
            )
            connection.commit()
        finally:
            Database.close_connection(connection, cursor)

    @staticmethod
    def delete(message_id, user_id):
        connection = Database.get_connection()
        cursor = connection.cursor()
        try:
            cursor.execute(
                """UPDATE messages 
                SET deleted_at = NOW() 
                WHERE id = %s AND user_id = %s""",
                (message_id, user_id)
            )
            connection.commit()
            return cursor.rowcount > 0
        finally:
            Database.close_connection(connection, cursor)