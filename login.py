import flet as ft
from db import conectar_db
import time
from datetime import datetime, date

def validar_login(email, contrasena):
    conn = conectar_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM usuarios WHERE email=%s AND contrasena=%s", (email, contrasena))
    usuario = cursor.fetchone()

    if usuario:
        hoy = date.today()
        ultimo_acceso = usuario.get('ultimo_acceso')
        if not ultimo_acceso or ultimo_acceso < hoy:
            try:
                cursor.execute(
                    "UPDATE usuarios SET monedas = monedas + 1, ultimo_acceso = %s WHERE id = %s",
                    (hoy, usuario['id'])
                )
                conn.commit()
                usuario['monedas'] += 1
                usuario['ultimo_acceso'] = hoy
            except Exception as e:
                print("Error al actualizar monedas:", e)

    cursor.close()
    conn.close()
    return usuario

def registrar_usuario(nombre, correo, contrasena, confirmar, trabaja, horas, estres, acepta):
    if contrasena != confirmar:
        return False, "Las contraseñas no coinciden"
    if not acepta:
        return False, "Debes aceptar los términos y condiciones"

    conn = conectar_db()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO usuarios 
            (nombre, email, contrasena, trabaja_actualmente, horas_trabajo_estudio, frecuencia_estres, acepta_terminos)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (nombre, correo, contrasena, trabaja, horas, estres, acepta))
        conn.commit()
        return True, "Usuario registrado correctamente"
    except Exception as e:
        return False, str(e)
    finally:
        cursor.close()
        conn.close()

def login_view(page: ft.Page):
    email = ft.TextField(label="Email", width=300)
    password = ft.TextField(label="Contraseña", password=True, width=300)
    mensaje = ft.Text(color="red")

    def login_click(e):
        user = validar_login(email.value, password.value)
        if user:
            mensaje.color = "green"
            mensaje.value = f"¡Bienvenido {user['nombre']}! Rol: {user.get('rol', 'usuario')}"
            from views import main_view
            page.controls.clear()
            main_view(page, user)
        else:
            mensaje.color = "red"
            mensaje.value = "Credenciales incorrectas"
        page.update()

    def switch_to_register(e):
        page.controls.clear()
        page.add(register_view(page))
        page.update()

    login_col = ft.Column(
        [
            ft.Text("Iniciar sesión", size=30),
            email,
            password,
            ft.ElevatedButton("Ingresar", on_click=login_click),
            ft.TextButton("Crear una cuenta nueva", on_click=switch_to_register),
            mensaje,
        ],
        alignment=ft.MainAxisAlignment.CENTER,
        horizontal_alignment=ft.CrossAxisAlignment.CENTER,
        spacing=15,
    )
    return login_col

def register_view(page: ft.Page):
    nombre = ft.TextField(label="Nombre completo", width=300)
    correo = ft.TextField(label="Correo institucional o personal", width=300)
    contrasena = ft.TextField(label="Contraseña", password=True, width=300)
    confirmar = ft.TextField(label="Confirmar contraseña", password=True, width=300)
    trabaja = ft.Dropdown(
        label="¿Trabajas actualmente?",
        options=[ft.dropdown.Option("Sí"), ft.dropdown.Option("No")],
        width=300,
    )
    horas = ft.TextField(label="¿Cuántas horas al día trabajas y estudias?", width=300)
    estres = ft.TextField(label="Frecuencia de estrés (Autopercibido)", width=300)
    
    acepta_checkbox = ft.Checkbox(label="Acepto términos y condiciones")
    acepta = ft.Row([acepta_checkbox], alignment=ft.MainAxisAlignment.CENTER)

    mensaje = ft.Text(color="red")

    def register_click(e):
        ok, msg = registrar_usuario(
            nombre.value, correo.value, contrasena.value, confirmar.value,
            trabaja.value, horas.value, estres.value, acepta_checkbox.value
        )
        if ok:
            mensaje.color = "green"
            mensaje.value = msg
            page.update()
            time.sleep(1.5)
            page.controls.clear()
            page.add(login_view(page))
            page.update()
        else:
            mensaje.color = "red"
            mensaje.value = msg
            page.update()

    def switch_to_login(e):
        page.controls.clear()
        page.add(login_view(page))
        page.update()

    return ft.Column(
        [
            ft.Text("Crear cuenta", size=30),
            nombre,
            correo,
            contrasena,
            confirmar,
            trabaja,
            horas,
            estres,
            acepta,  
            ft.ElevatedButton("Registrar", on_click=register_click), 
            ft.TextButton("Volver al login", on_click=switch_to_login),
            mensaje,
        ],
        alignment=ft.MainAxisAlignment.CENTER,
        horizontal_alignment=ft.CrossAxisAlignment.CENTER,
        spacing=10,
    )
