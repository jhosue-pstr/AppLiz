import flet as ft
from db import obtener_notas
from db import guardar_nota_en_bd
from db import eliminar_nota_en_bd

def main_view(page: ft.Page, usuario: dict):
    from views import perfil_view 
    page.clean()

    logo = ft.Text("🧠 App Liz", size=40, weight="bold", text_align="center")
    bienvenida = ft.Text(f"Bienvenido, {usuario['nombre']} 👋", size=24)
    monedas = ft.Text(f"💰 Monedas: {usuario['monedas']}", size=18, weight="bold")

    def ir_perfil(e):
        perfil_view(page, usuario)

    def ir_diario(e):
        diario_view(page, usuario)

    def ir_herramientas(e):
        gestion_view(page , usuario)
        
    opciones = [
        ("👤 Perfil", ft.Colors.PURPLE_400, ir_perfil),
        ("📓 Diario / Notas", ft.Colors.RED_400, ir_diario),
        ("🌐 Comunidad", ft.Colors.CYAN_300, lambda e: print("Ir a Comunidad")),
        ("🧰 Herramientas de Gestión", ft.Colors.GREEN_400,  ir_herramientas),
        ("📚 Recursos de Apoyo", ft.Colors.BLUE_400, lambda e: print("Ir a Recursos")),
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
                logo,
                ft.Row([bienvenida, ft.Container(expand=True), monedas]),
                ft.Divider(height=10),
                grid
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
        "Información Personal",
        "Inicio de Sesión y Seguridad",
        "Pagos y Cobros",
        "Accesibilidad",
        "Obten ayuda",
        "Traducción",
        "Política de privacidad",
        "Licencias de código abierto"
    ]

    configuraciones = ft.Column([
        ft.Text("Configuración", size=18, weight="bold"),
        *[
            ft.ListTile(
                title=ft.Text(opcion),
                trailing=ft.Icon(ft.Icons.KEYBOARD_ARROW_RIGHT),
                dense=True
            ) for opcion in opciones
        ]
    ])

    boton_volver = ft.ElevatedButton("Volver", on_click=lambda e: main_view(page, usuario))

    page.add(
        ft.Column([
            header,
            ft.Divider(),
            configuraciones,
            ft.Divider(),
            boton_volver
        ], scroll=ft.ScrollMode.AUTO, spacing=20, expand=True)
    )
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
                    on_click=lambda e: page.dialog(ft.AlertDialog(title=ft.Text("Tareas aún no implementado.")))
                ),
                ft.ElevatedButton(
                    "🚨 Incidencias", 
                    style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), 
                    width=300,
                    on_click=lambda e: page.dialog(ft.AlertDialog(title=ft.Text("Incidencias aún no implementado.")))
                ),
                ft.ElevatedButton(
                    "📅 Eventos", 
                    style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=30)), 
                    width=300,
                    on_click=lambda e: page.dialog(ft.AlertDialog(title=ft.Text("Eventos aún no implementado.")))
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
