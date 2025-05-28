import mysql.connector

def conectar_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="AppLiz"
    )




def obtener_usuario_por_id(id_usuario: int) -> dict:
    conexion = conectar_db()
    cursor = conexion.cursor(dictionary=True)
    cursor.execute("SELECT * FROM usuarios WHERE id = %s", (id_usuario,))
    usuario = cursor.fetchone()
    cursor.close()
    conexion.close()
    return usuario



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




def obtener_tareas(usuario_id):
    conn = conectar_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM tareas WHERE usuario_id = %s", (usuario_id,))
    tareas = cursor.fetchall()
    cursor.close()
    conn.close()
    return tareas

def guardar_tarea_en_bd(usuario_id, titulo, descripcion, fecha_vencimiento, estado, prioridad):
    conn = conectar_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO tareas (usuario_id, titulo, descripcion, fecha_vencimiento, estado, prioridad)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (usuario_id, titulo, descripcion, fecha_vencimiento, estado, prioridad))
    conn.commit()
    cursor.close()
    conn.close()


def eliminar_tarea_en_bd(usuario_id, tarea_id):
    conn = conectar_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM tareas WHERE id = %s AND usuario_id = %s", (tarea_id, usuario_id))
    conn.commit()
    cursor.close()
    conn.close()


def obtener_incidencias(usuario_id):
    conn = conectar_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM incidencias WHERE usuario_id = %s", (usuario_id,))
    incidencias = cursor.fetchall()
    cursor.close()
    conn.close()
    return incidencias

def guardar_incidencia_en_bd(usuario_id, titulo, descripcion, estado, prioridad):
    conn = conectar_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO incidencias (usuario_id, titulo, descripcion, estado, prioridad)
        VALUES (%s, %s, %s, %s, %s)
    """, (usuario_id, titulo, descripcion, estado, prioridad))
    conn.commit()
    cursor.close()
    conn.close()

def eliminar_incidencia_en_bd(usuario_id, incidencia_id):
    conn = conectar_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM incidencias WHERE id = %s AND usuario_id = %s", (incidencia_id, usuario_id))
    conn.commit()
    cursor.close()
    conn.close()


def obtener_eventos():
    conn = conectar_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM eventos")
    eventos = cursor.fetchall()
    cursor.close()
    conn.close()
    return eventos

def guardar_evento_en_bd(titulo, descripcion, fecha_inicio, fecha_fin, lugar, creado_por):
    conn = conectar_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO eventos (titulo, descripcion, fecha_inicio, fecha_fin, lugar, creado_por)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (titulo, descripcion, fecha_inicio, fecha_fin, lugar, creado_por))
    conn.commit()
    cursor.close()
    conn.close()

def eliminar_evento_en_bd(evento_id):
    conn = conectar_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM eventos WHERE id = %s", (evento_id,))
    conn.commit()
    cursor.close()
    conn.close()
