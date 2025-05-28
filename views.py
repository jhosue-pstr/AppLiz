import flet as ft
from db import *
from login import *

def main_view(page: ft.Page, usuario: dict):
    page.clean()

    logo = ft.Image(src="assets/logo.jpeg", width=150, height=150)
    bienvenida = ft.Text(f"Bienvenido, {usuario['nombre']} 👋", size=24, text_align="center")
    monedas = ft.Text(f"💰 Monedas: {usuario['monedas']}", size=18, weight="bold")

    def cerrar_sesion(e):
        page.clean()
        page.add(login_view(page))
        page.update()

    cerrar_btn = ft.ElevatedButton(
        "Cerrar sesión",
        on_click=cerrar_sesion,
        style=ft.ButtonStyle(bgcolor=ft.Colors.RED_400, color="white")
    )
    fila_superior = ft.Row(
        [ft.Container(expand=True), cerrar_btn],
        alignment=ft.MainAxisAlignment.END
    )
    logo_centrado = ft.Row(
        [logo],
        alignment=ft.MainAxisAlignment.CENTER
    )
    bienvenida_centrada = ft.Row(
        [bienvenida],
        alignment=ft.MainAxisAlignment.CENTER
    )
    monedas_derecha = ft.Row(
        [ft.Container(expand=True), monedas],
        alignment=ft.MainAxisAlignment.SPACE_BETWEEN
    )
    opciones = [
        ("👤 Perfil", ft.Colors.PURPLE_400, lambda e: perfil_view(page, usuario)),
        ("📓 Diario / Notas", ft.Colors.RED_400, lambda e: diario_view(page, usuario)),
        ("🌐 Comunidad", ft.Colors.CYAN_300, lambda e: print("Ir a Comunidad")),
        ("🧰 Herramientas de Gestión", ft.Colors.GREEN_400, lambda e: gestion_view(page, usuario)),
        ("📚 Recursos de Apoyo", ft.Colors.BLUE_400, lambda e: recursos_view(page, usuario)),
    ]

    botones = []
    for titulo, color, accion in opciones:
        boton = ft.Container(
            content=ft.Text(titulo, size=16, weight="bold", text_align="center"),
            alignment=ft.alignment.center,
            width=200,
            height=120,
            bgcolor=color,
            border_radius=10,
            ink=True,
            on_click=accion,
        )
        botones.append(boton)

    grid = ft.Row(
        [ft.Column(botones[:3], spacing=10), ft.Column(botones[3:], spacing=10)],
        alignment=ft.MainAxisAlignment.CENTER,
        spacing=30,
    )

    page.add(
        ft.Column(
            [
                fila_superior,
                logo_centrado,
                bienvenida_centrada,
                monedas_derecha,
                ft.Divider(height=10),
                grid,
            ],
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            spacing=20,
        )
    )
    page.update()



def perfil_view(page: ft.Page, usuario: dict):
    from views import main_view
    page.clean()

    header = ft.Column([
        ft.Text("Tu Perfil", size=24, weight="bold"),
        ft.Row([
            ft.CircleAvatar(
                content=ft.Text(usuario['nombre'][0], size=20),
                radius=30
            ),
            ft.Column([
                ft.Text(usuario['nombre'], size=20, weight="bold"),
                ft.Text(f"Anfitrión {usuario['nombre'].split()[0]}", italic=True, color="gray"),
                ft.Text('"Tu bienestar emocional, tu mejor herramienta."', size=12, italic=True),
            ], spacing=2)
        ], alignment="start", spacing=10)
    ])

    opciones = [
        ("Información Personal", lambda e: informacion_personal_view(page, usuario)),
        ("Inicio de Sesión y Seguridad", None),
        ("Pagos y Cobros", None),
        ("Accesibilidad", None),
        ("Obtén ayuda", None),
        ("Traducción", None),
        ("Política de privacidad", None),
        ("Licencias de código abierto", None)
    ]
    configuraciones = ft.Column([
        ft.Text("Configuración", size=18, weight="bold"),
        *[
            ft.ElevatedButton(
                text=opcion[0],
                on_click=opcion[1] if opcion[1] else lambda e: None,
                width=300,
                style=ft.ButtonStyle(
                    shape=ft.RoundedRectangleBorder(radius=5),
                    padding=10
                )
            )
            for opcion in opciones
        ]
    ], spacing=10)

    configuraciones_centrada = ft.Row(
        [configuraciones],
        alignment=ft.MainAxisAlignment.CENTER
    )

    page.add(
        ft.Column([
            header,
            ft.Divider(),
            configuraciones_centrada,
            ft.Divider(),
            ft.Row(
                [ft.ElevatedButton("Volver al inicio", on_click=lambda e: main_view(page, usuario))],
                alignment=ft.MainAxisAlignment.CENTER
            )
        ], scroll=ft.ScrollMode.AUTO, spacing=20, expand=True)
    )
    page.update()

def informacion_personal_view(page: ft.Page, usuario: dict):
    from views import perfil_view  

    page.clean()
    page.title = "Información Personal"

    datos = ft.Column([
        ft.Text("Información Personal", size=24, weight="bold"),
        ft.Divider(),
        ft.Text(f"Nombre: {usuario.get('nombre', '')}"),
        ft.Text(f"Email: {usuario.get('email', '')}"),
        ft.Text(f"Rol: {usuario.get('rol', '')}"),
        ft.Text(f"Monedas: {usuario.get('monedas', 0)}"),
        ft.Text(f"Último acceso: {usuario.get('ultimo_acceso', '')}"),
        ft.Text(f"Trabaja actualmente: {usuario.get('trabaja_actualmente', '')}"),
        ft.Text(f"Horas de trabajo/estudio: {usuario.get('horas_trabajo_estudio', '')}"),
        ft.Text(f"Frecuencia de estrés: {usuario.get('frecuencia_estres', '')}"),
        ft.Text(f"Acepta términos: {'Sí' if usuario.get('acepta_terminos') else 'No'}"),
    ], spacing=8)

    btn_volver = ft.ElevatedButton("Volver", on_click=lambda e: perfil_view(page, usuario))

    page.add(datos, btn_volver)
    page.update()




def diario_view(page: ft.Page, usuario: dict):
    from views import main_view

    page.clean()

    page.add(
        ft.Column(
            controls=[
                ft.Text("📔 Diario Emocional", size=30, weight="bold", text_align="center"),
                ft.Container(
                    content=ft.Row(
                        controls=[
                            ft.Text("😡", size=30),
                            ft.Text("😟", size=30),
                            ft.Text("😐", size=30),
                            ft.Text("😊", size=30),
                            ft.Text("😁", size=30),
                        ],
                        alignment=ft.MainAxisAlignment.CENTER
                    ),
                    margin=10
                ),
                ft.ElevatedButton("Historial emocional", style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), width=300),
                ft.ElevatedButton("Gráfico semanal/mensual", style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), width=300),
                ft.ElevatedButton("Promedio de estado emocional", style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), width=300),
                ft.ElevatedButton("Detección de patrones", style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), width=300),
                ft.ElevatedButton("Volver", on_click=lambda e: main_view(page, usuario))

            ],
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            alignment=ft.MainAxisAlignment.CENTER,
            spacing=20
        )
    )

    page.update()



def gestion_view(page: ft.Page, usuario: dict):
    from views import main_view, notas_view  

    page.clean()
    page.title = "Herramientas de Gestión"

    def ir_notas(e):
        notas_view(page, usuario)
            

    def ir_eventos(e):
        eventos_view(page, usuario)
               

    def ir_tareas(e):
        tareas_view(page, usuario)
           
    def ir_incidencias(e):
        incidencias_view(page, usuario)
           
    page.add(
        ft.Column(
            controls=[
                ft.Text("🛠️ Herramientas de Gestión", size=30, weight="bold", text_align="center"),

                ft.ElevatedButton(
                    "📄 Notas", 
                    style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), 
                    width=300, 
                    on_click=ir_notas  
                ),
                ft.ElevatedButton(
                    "✅ Tareas", 
                    style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), 
                    width=300,
                    on_click=ir_tareas
                ),
                ft.ElevatedButton(
                    "🚨 Incidencias", 
                    style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), 
                    width=300,
                    on_click=ir_incidencias
                ),
                ft.ElevatedButton(
                    "📅 Eventos", 
                    style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), 
                    width=300,
                    on_click= ir_eventos
                ),
                ft.ElevatedButton(
                    "🧑‍🤝‍🧑 Asistencias", 
                    style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), 
                    width=300,
                    on_click=lambda e: page.dialog(ft.AlertDialog(title=ft.Text("Asistencias aún no implementado.")))
                ),
                ft.ElevatedButton(
                    "🔒 Cerrar periodo", 
                    style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), 
                    width=300,
                    on_click=lambda e: page.dialog(ft.AlertDialog(title=ft.Text("Cerrar periodo aún no implementado.")))
                ),
                ft.ElevatedButton("Volver", on_click=lambda e: main_view(page, usuario))
            ],
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            alignment=ft.MainAxisAlignment.CENTER,
            spacing=20
        )
    )

    page.update()


def notas_view(page: ft.Page, usuario: dict):
    page.clean()
    page.title = "Notas"

    usuario_id = usuario.get("id")  
    contenedor = ft.Column(scroll=ft.ScrollMode.AUTO)

    def cargar_notas():
        contenedor.controls.clear()
        notas = obtener_notas(usuario_id)

        if notas:
            for nota in notas:
                def eliminar_nota(e, nota_id=nota["id"]):
                    eliminar_nota_en_bd(usuario_id, nota_id)
                    cargar_notas() 

                contenedor.controls.append(
                    ft.Card(
                        content=ft.Row(
                            controls=[
                                ft.Column(
                                    controls=[
                                        ft.Text(nota.get("titulo", "Sin título")),
                                        ft.Text(nota.get("contenido", ""))
                                    ],
                                    expand=True,
                                ),
                                ft.IconButton(icon=ft.Icons.DELETE, on_click=eliminar_nota)
                            ]
                        )
                    )
                )
        else:
            contenedor.controls.append(
                ft.Text("Sin notas", style="titleMedium", color=ft.Colors.GREY)
            )
        page.update()

    def agregar_nota(e):
        nueva_nota_view(page, usuario)

    def volver(e):
        from views import gestion_view
        gestion_view(page, usuario)

    cargar_notas()

    page.add(
        ft.AppBar(title=ft.Text("Notas"), bgcolor=ft.Colors.SURFACE),
        contenedor,
        ft.Row(
            controls=[
                ft.FloatingActionButton(icon=ft.Icons.ADD, on_click=agregar_nota),
                ft.FloatingActionButton(icon=ft.Icons.ARROW_BACK, on_click=volver),
            ],
            alignment=ft.MainAxisAlignment.END
        )
    )
    page.update()





def nueva_nota_view(page: ft.Page, usuario: dict):
    page.clean()
    page.title = "Nueva Nota"

    titulo_input = ft.TextField(label="Título", width=500)
    contenido_input = ft.TextField(label="Contenido", multiline=True, min_lines=5, max_lines=10, width=500)

    def guardar_nota(e):
        usuario_id = usuario.get("id")
        titulo = titulo_input.value
        contenido = contenido_input.value

        guardar_nota_en_bd(usuario_id, titulo, contenido)

        page.snack_bar = ft.SnackBar(
            content=ft.Text("Nota guardada correctamente"), 
            bgcolor=ft.Colors.GREEN
        )
        page.snack_bar.open = True
        page.update()

        notas_view(page, usuario)

    def volver(e):
        notas_view(page, usuario)

    page.add(
        ft.Text("📝 Crear Nueva Nota", size=25, weight="bold"),
        titulo_input,
        contenido_input,
        ft.Row(
            controls=[
                ft.ElevatedButton("Guardar", icon=ft.Icons.SAVE, on_click=guardar_nota),
                ft.ElevatedButton("Cancelar", icon=ft.Icons.CANCEL, on_click=volver)
            ],
            spacing=20
        )
    )
    page.update()


def tareas_view(page: ft.Page, usuario: dict):
    from views import gestion_view
    page.clean()
    page.title = "Tareas"
    usuario_id = usuario["id"]
    contenedor = ft.Column(scroll=ft.ScrollMode.AUTO)

    def cargar_tareas():
        contenedor.controls.clear()
        tareas = obtener_tareas(usuario_id)  

        if tareas:
            for tarea in tareas:
                def eliminar(e, id=tarea["id"]):
                    eliminar_tarea_en_bd(usuario_id, id)
                    cargar_tareas()

                contenedor.controls.append(
                    ft.Card(
                        content=ft.Row(
                            controls=[
                                ft.Column([
                                    ft.Text(f"Título: {tarea['titulo']}"),
                                    ft.Text(f"Descripción: {tarea.get('descripcion', '')}"),
                                    ft.Text(f"Vence: {tarea.get('fecha_vencimiento', '')}"),
                                    ft.Text(f"Estado: {tarea.get('estado', '')}"),
                                    ft.Text(f"Prioridad: {tarea.get('prioridad', '')}")
                                ], expand=True),
                                ft.IconButton(icon=ft.Icons.DELETE, on_click=eliminar)
                            ]
                        )
                    )
                )
        else:
            contenedor.controls.append(ft.Text("Sin tareas", color=ft.Colors.GREY))

        page.update()

    def agregar(e): 
        nueva_tarea_view(page, usuario)
        
    def volver(e): 
        gestion_view(page, usuario)

    cargar_tareas()

    page.add(
        ft.AppBar(title=ft.Text("Tareas")),
        contenedor,
        ft.Row([
            ft.FloatingActionButton(icon=ft.Icons.ADD, on_click=agregar),
            ft.FloatingActionButton(icon=ft.Icons.ARROW_BACK, on_click=volver)
        ], alignment=ft.MainAxisAlignment.END)
    )
    page.update()


def nueva_tarea_view(page: ft.Page, usuario: dict):
    page.clean()
    page.title = "Nueva Tarea"

    titulo = ft.TextField(label="Título", width=500)
    descripcion = ft.TextField(label="Descripción", multiline=True, width=500)
    prioridad = ft.Dropdown(
        label="Prioridad",
        options=[
            ft.dropdown.Option("Alta"),
            ft.dropdown.Option("Media"),
            ft.dropdown.Option("Baja")
        ],
        width=200,
        value="Media"
    )
    estado = ft.Dropdown(
        label="Estado",
        options=[
            ft.dropdown.Option("pendiente"),
            ft.dropdown.Option("en progreso"),
            ft.dropdown.Option("completada"),
        ],
        width=200,
        value="pendiente"
    )

    fecha_vencimiento = ft.TextField(label="Fecha de vencimiento", read_only=True, width=200)
    date_picker = ft.DatePicker(
        on_change=lambda e: actualizar_fecha()
    )

    page.overlay.append(date_picker)
    page.update()

    def actualizar_fecha():
        fecha_vencimiento.value = str(date_picker.value)
        fecha_vencimiento.update()

    def seleccionar_fecha(e):
        date_picker.open = True
        page.update()

    btn_fecha = ft.IconButton(icon=ft.Icons.CALENDAR_MONTH, on_click=seleccionar_fecha)

    def guardar(e):
        prio = prioridad.value if prioridad.value else "Media"
        est = estado.value if estado.value else "pendiente"

        guardar_tarea_en_bd(
            usuario["id"],
            titulo.value,
            descripcion.value,
            fecha_vencimiento.value,
            est,
            prio
        )

        page.snack_bar = ft.SnackBar(content=ft.Text("Tarea guardada"), bgcolor=ft.Colors.GREEN)
        page.snack_bar.open = True
        page.update()

        tareas_view(page, usuario)

    def volver(e):
        tareas_view(page, usuario)

    page.add(
        ft.Text("📋 Crear Nueva Tarea", size=25, weight="bold"),
        titulo,
        descripcion,
        ft.Row([fecha_vencimiento, btn_fecha]),
        prioridad,
        estado,
        ft.Row([
            ft.ElevatedButton("Guardar", icon=ft.Icons.SAVE, on_click=guardar),
            ft.ElevatedButton("Cancelar", icon=ft.Icons.CANCEL, on_click=volver),
        ], spacing=20)
    )
    page.update()



def incidencias_view(page: ft.Page, usuario: dict):
    from views import gestion_view
    page.clean()
    page.title = "Incidencias"
    usuario_id = usuario["id"]
    contenedor = ft.Column(scroll=ft.ScrollMode.AUTO)

    def cargar():
        contenedor.controls.clear()
        datos = obtener_incidencias(usuario_id)

        if datos:
            for inc in datos:
                def eliminar(e, id=inc["id"]):
                    eliminar_incidencia_en_bd(usuario_id, id)
                    cargar()

                contenedor.controls.append(
                    ft.Card(
                        content=ft.Row([
                            ft.Column([
                                ft.Text(f"Título: {inc['titulo']}"),
                                ft.Text(f"Descripción: {inc.get('descripcion', '')}"),
                                ft.Text(f"Estado: {inc.get('estado', '')}"),
                                ft.Text(f"Prioridad: {inc.get('prioridad', '')}"),
                                ft.Text(f"Fecha: {inc.get('fecha_reporte', '')}")
                            ], expand=True),
                            ft.IconButton(icon=ft.Icons.DELETE, on_click=eliminar)
                        ])
                    )
                )
        else:
            contenedor.controls.append(ft.Text("Sin incidencias registradas", color=ft.Colors.GREY))
        page.update()

    def agregar(e): nueva_incidencia_view(page, usuario)
    def volver(e): gestion_view(page, usuario)

    cargar()

    page.add(
        ft.AppBar(title=ft.Text("Incidencias")),
        contenedor,
        ft.Row([
            ft.FloatingActionButton(icon=ft.Icons.ADD, on_click=agregar),
            ft.FloatingActionButton(icon=ft.Icons.ARROW_BACK, on_click=volver)
        ], alignment=ft.MainAxisAlignment.END)
    )
    page.update()

def nueva_incidencia_view(page: ft.Page, usuario: dict):
    page.clean()
    titulo = ft.TextField(label="Título", width=500)
    descripcion = ft.TextField(label="Descripción", multiline=True, width=500)
    prioridad = ft.Dropdown(
        label="Prioridad", 
        options=[
            ft.dropdown.Option("baja"), 
            ft.dropdown.Option("media"), 
            ft.dropdown.Option("alta")
        ], 
        width=500,
        value="media"
    )
    estado = ft.Dropdown(
    label="Estado",
    options=[
        ft.dropdown.Option("abierta"),
        ft.dropdown.Option("en proceso"),
        ft.dropdown.Option("cerrada"),
    ],
    width=500,
    value="abierta"
)


    def guardar(e):
        guardar_incidencia_en_bd(
            usuario["id"],
            titulo.value,
            descripcion.value,
            estado.value or "pendiente",
            prioridad.value or "media"
        )
        incidencias_view(page, usuario)

    def cancelar(e): 
        incidencias_view(page, usuario)

    page.add(
        ft.Text("🚨 Nueva Incidencia", size=25, weight="bold"),
        titulo,
        descripcion,
        prioridad,
        estado,
        ft.Row([
            ft.ElevatedButton("Guardar", icon=ft.Icons.SAVE, on_click=guardar),
            ft.ElevatedButton("Cancelar", icon=ft.Icons.CANCEL, on_click=cancelar)
        ], spacing=20)
    )
    page.update()


def eventos_view(page: ft.Page, usuario: dict):
    from views import gestion_view
    page.clean()
    page.title = "Eventos"
    contenedor = ft.Column(scroll=ft.ScrollMode.AUTO)

    def cargar():
        contenedor.controls.clear()
        eventos = obtener_eventos()

        if eventos:
            for evento in eventos:
                def eliminar(e, id=evento["id"]):
                    eliminar_evento_en_bd(id)
                    cargar()

                contenedor.controls.append(
                    ft.Card(
                        content=ft.Row([
                            ft.Column([
                                ft.Text(f"Título: {evento['titulo']}"),
                                ft.Text(f"Descripción: {evento['descripcion']}"),
                                ft.Text(f"Inicio: {evento['fecha_inicio']}"),
                                ft.Text(f"Fin: {evento.get('fecha_fin', 'No especificado')}"),
                                ft.Text(f"Lugar: {evento.get('lugar', '')}")
                            ], expand=True),
                            ft.IconButton(icon=ft.Icons.DELETE, on_click=eliminar)
                        ])
                    )
                )
        else:
            contenedor.controls.append(ft.Text("No hay eventos", color=ft.Colors.GREY))
        page.update()

    def agregar(e): nuevo_evento_view(page, usuario)
    def volver(e): gestion_view(page, usuario)

    cargar()

    page.add(
        ft.AppBar(title=ft.Text("Eventos")),
        contenedor,
        ft.Row([
            ft.FloatingActionButton(icon=ft.Icons.ADD, on_click=agregar),
            ft.FloatingActionButton(icon=ft.Icons.ARROW_BACK, on_click=volver)
        ], alignment=ft.MainAxisAlignment.END)
    )

def nuevo_evento_view(page: ft.Page, usuario: dict):
    page.clean()
    page.title = "Nuevo Evento"

    titulo = ft.TextField(label="Título", width=500)
    descripcion = ft.TextField(label="Descripción", multiline=True, width=500)
    lugar = ft.TextField(label="Lugar", width=500)

    fecha_inicio_text = ft.TextField(label="Fecha de inicio", read_only=True, width=200)
    fecha_fin_text = ft.TextField(label="Fecha fin", read_only=True, width=200)

    fecha_inicio_picker = ft.DatePicker(
        on_change=lambda e: actualizar_fecha_inicio()
    )
    fecha_fin_picker = ft.DatePicker(
        on_change=lambda e: actualizar_fecha_fin()
    )

    page.overlay.append(fecha_inicio_picker)
    page.overlay.append(fecha_fin_picker)

    def actualizar_fecha_inicio():
        fecha_inicio_text.value = str(fecha_inicio_picker.value) if fecha_inicio_picker.value else ""
        fecha_inicio_text.update()

    def actualizar_fecha_fin():
        fecha_fin_text.value = str(fecha_fin_picker.value) if fecha_fin_picker.value else ""
        fecha_fin_text.update()

    def abrir_fecha_inicio(e):
        fecha_inicio_picker.open = True
        page.update()

    def abrir_fecha_fin(e):
        fecha_fin_picker.open = True
        page.update()

    btn_fecha_inicio = ft.IconButton(icon=ft.Icons.CALENDAR_MONTH, on_click=abrir_fecha_inicio)
    btn_fecha_fin = ft.IconButton(icon=ft.Icons.CALENDAR_MONTH, on_click=abrir_fecha_fin)

    def guardar(e):
        guardar_evento_en_bd(
            titulo.value,
            descripcion.value,
            fecha_inicio_text.value,
            fecha_fin_text.value,
            lugar.value,
            creado_por=usuario["id"]
        )
        eventos_view(page, usuario)

    def cancelar(e):
        eventos_view(page, usuario)

    page.add(
        ft.Text("📅 Nuevo Evento", size=25, weight="bold"),
        titulo,
        descripcion,
        ft.Row([fecha_inicio_text, btn_fecha_inicio], spacing=5),
        ft.Row([fecha_fin_text, btn_fecha_fin], spacing=5),
        lugar,
        ft.Row([
            ft.ElevatedButton("Guardar", icon=ft.Icons.SAVE, on_click=guardar),
            ft.ElevatedButton("Cancelar", icon=ft.Icons.CANCEL, on_click=cancelar),
        ], spacing=20)
    )
    page.update()







import random

def recursos_view(page: ft.Page, usuario: dict):
    from views import main_view

    def volver_inicio(e):
        main_view(page, usuario)

    def ir_frase_dia(e):
        frase_dia_view(page, usuario)

    def ir_enlaces_utiles(e):
        enlaces_utiles_view(page, usuario)

    def ir_video(e):
        video_view(page, usuario)

    def ir_libros(e):
        libros_view(page, usuario)

    def ir_profesional(e):
        ayuda_profesional_view(page, usuario)

    def ir_test(e):
        test_emocional_view(page, usuario)

    page.clean()
    page.add(
        ft.Column(
            controls=[
                ft.Text("📚 Recursos de Apoyo", size=30, weight="bold", text_align="center"),

                ft.ElevatedButton("🔗 Enlaces útiles", style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), width=300, on_click=ir_enlaces_utiles),
                ft.ElevatedButton("🧠 Frase del día", style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), width=300, on_click=ir_frase_dia),
                ft.ElevatedButton("▶️ Video recomendado", style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), width=300, on_click=ir_video),
                ft.ElevatedButton("📘 Libros y PDFs", style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), width=300, on_click=ir_libros),
                ft.ElevatedButton("🆘 Ayuda profesional", style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), width=300, on_click=ir_profesional),
                ft.ElevatedButton("📝 Test emocional", style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), width=300, on_click=ir_test),

                ft.ElevatedButton("⬅️ Volver", on_click=volver_inicio)
            ],
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            alignment=ft.MainAxisAlignment.CENTER,
            spacing=20
        )
    )



def frase_dia_view(page: ft.Page, usuario: dict):
    frases = [
        "Cuida tu mente como cuidas tu cuerpo.",
        "Pequeños pasos también te acercan a tu meta.",
        "Respira. Todo pasa.",
        "Tu salud mental es prioridad.",
        "Eres más fuerte de lo que piensas.",
        "Está bien pedir ayuda.",
    ]
    frase = random.choice(frases)

    def volver(e):
        recursos_view(page, usuario)

    page.clean()
    page.add(
        ft.Column([
            ft.Text("🧠 Frase del Día", size=28, weight="bold"),
            ft.Container(
                content=ft.Text(f'"{frase}"', size=20, italic=True),
                bgcolor=ft.Colors.BLUE_100,
                padding=20,
                border_radius=10
            ),
            ft.ElevatedButton("⬅️ Volver", on_click=volver)
        ],
        horizontal_alignment=ft.CrossAxisAlignment.CENTER,
        alignment=ft.MainAxisAlignment.CENTER,
        spacing=20)
    )



def enlaces_utiles_view(page: ft.Page, usuario: dict):
    def volver(e):
        recursos_view(page, usuario)

    def abrir(url):
        def handler(e):
            page.launch_url(url)
        return handler

    page.clean()
    page.add(
        ft.Column([
            ft.Text("🔗 Enlaces Útiles", size=28, weight="bold"),
            ft.ElevatedButton("Ansiedad: Guía de ayuda", on_click=abrir("https://www.who.int/es/news-room/questions-and-answers/item/mental-health-strengthening-our-response")),
            ft.ElevatedButton("Depresión: Apoyo y recursos", on_click=abrir("https://www.unicef.org/es/salud-mental")),
            ft.ElevatedButton("Mindfulness para principiantes", on_click=abrir("https://mindful.org/mindfulness-how-to-do-it/")),
            ft.ElevatedButton("⬅️ Volver", on_click=volver)
        ],
        horizontal_alignment=ft.CrossAxisAlignment.CENTER,
        spacing=15)
    )


def video_view(page: ft.Page, usuario: dict):
    def volver(e):
        recursos_view(page, usuario)

    page.clean()
    page.add(
        ft.Column(
            controls=[
                ft.Text("▶️ Video recomendado", size=28, weight="bold", text_align="center"),
                ft.Text("Aprende a manejar el estrés con este video informativo.", size=18),
                ft.ElevatedButton("Ver video", on_click=lambda e: page.launch_url("https://www.youtube.com/watch?v=hnpQrMqDoqE")),
                ft.ElevatedButton("⬅️ Volver", on_click=volver)
            ],
            spacing=20,
            alignment=ft.MainAxisAlignment.CENTER,
            horizontal_alignment=ft.CrossAxisAlignment.CENTER
        )
    )
    page.update()



def libros_view(page: ft.Page, usuario: dict):
    def volver(e):
        recursos_view(page, usuario)

    page.clean()
    page.add(
        ft.Column(
            controls=[
                ft.Text("📚 Libros y PDFs Gratuitos", size=28, weight="bold", text_align="center"),
                ft.ListView(
                    controls=[
                        ft.ListTile(title=ft.Text("Ebook: Inteligencia emocional"), on_click=lambda e: page.launch_url("https://www.freelibros.net/psicologia/inteligencia-emocional-pdf")),
                        ft.ListTile(title=ft.Text("PDF: Aprende a calmarte"), on_click=lambda e: page.launch_url("https://drive.google.com/file/d/1LM7U7xV...")),
                    ],
                    height=150
                ),
                ft.ElevatedButton("⬅️ Volver", on_click=volver)
            ],
            spacing=20,
            alignment=ft.MainAxisAlignment.CENTER,
            horizontal_alignment=ft.CrossAxisAlignment.CENTER
        )
    )
    page.update()




def ayuda_profesional_view(page: ft.Page, usuario: dict):
    def volver(e):
        recursos_view(page, usuario)

    page.clean()
    page.add(
        ft.Column(
            controls=[
                ft.Text("🆘 Ayuda Profesional", size=28, weight="bold", text_align="center"),
                ft.Text("Puedes contactar a un profesional de salud mental en los siguientes recursos:", size=18),
                ft.ListView(
                    controls=[
                        ft.ListTile(title=ft.Text("Psicólogos Perú"), on_click=lambda e: page.launch_url("https://www.psicologosperu.pe")),
                        ft.ListTile(title=ft.Text("Línea 100 – Ayuda emocional en Perú"), on_click=lambda e: page.launch_url("https://www.linea100.gob.pe")),
                    ],
                    height=100
                ),
                ft.ElevatedButton("⬅️ Volver", on_click=volver)
            ],
            spacing=20,
            alignment=ft.MainAxisAlignment.CENTER,
            horizontal_alignment=ft.CrossAxisAlignment.CENTER
        )
    )
    page.update()




def test_emocional_view(page: ft.Page, usuario: dict):
    def volver(e):
        recursos_view(page, usuario)

    page.clean()
    page.add(
        ft.Column(
            controls=[
                ft.Text("📝 Test Emocional", size=28, weight="bold", text_align="center"),
                ft.Text("Realiza este test para conocer tu estado emocional actual.", size=18),
                ft.ElevatedButton("Iniciar Test de Depresión de Beck", on_click=lambda e: page.launch_url("https://www.testpsicologicos.com/test-de-depresion-beck/")),
                ft.ElevatedButton("⬅️ Volver", on_click=volver)
            ],
            spacing=20,
            alignment=ft.MainAxisAlignment.CENTER,
            horizontal_alignment=ft.CrossAxisAlignment.CENTER
        )
    )
    page.update()
