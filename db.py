import mysql.connector

def conectar_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="AppLiz"
    )


def obtener_notas(usuario_id):
    conn = conectar_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM notas WHERE usuario_id = %s ORDER BY fecha_creacion DESC", (usuario_id,))
    notas = cursor.fetchall()
    conn.close()
    return notas



def guardar_nota_en_bd(usuario_id, titulo, contenido):
    conexion = conectar_db()
    cursor = conexion.cursor()
    cursor.execute("INSERT INTO notas (usuario_id, titulo, contenido) VALUES (%s, %s, %s)", (usuario_id, titulo, contenido))
    conexion.commit()
    conexion.close()


def eliminar_nota_en_bd(usuario_id, nota_id):
    conexion = conectar_db()
    cursor = conexion.cursor()
    cursor.execute("DELETE FROM notas WHERE id = %s AND usuario_id = %s", (nota_id, usuario_id))
    conexion.commit()
    conexion.close()
