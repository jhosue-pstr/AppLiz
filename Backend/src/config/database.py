import mysql.connector
from mysql.connector import pooling

class Database:
    __connection_pool = None

    @classmethod
    def initialize(cls):
        cls.__connection_pool = pooling.MySQLConnectionPool(
            pool_name="uni_pulse_pool",
            pool_size=5,
            host="localhost",
            user="root",
            password="",
            database="UniPulse",
            port=3306
        )

    @classmethod
    def get_connection(cls):
        return cls.__connection_pool.get_connection()

    @classmethod
    def close_connection(cls, connection, cursor=None):
        if cursor:
            cursor.close()
        connection.close()

Database.initialize()