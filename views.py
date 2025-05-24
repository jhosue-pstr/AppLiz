import flet as ft

def main_view(page: ft.Page, usuario: dict):
    from views import perfil_view  # se puede hacer esto porque ya no hay ciclo
    page.clean()

    logo = ft.Text("🧠 App Liz", size=40, weight="bold", text_align="center")
    bienvenida = ft.Text(f"Bienvenido, {usuario['nombre']} 👋", size=24)
    monedas = ft.Text(f"💰 Monedas: {usuario['monedas']}", size=18, weight="bold")

    def ir_perfil(e):
        perfil_view(page, usuario)

    opciones = [
        ("👤 Perfil", ft.Colors.PURPLE_400, ir_perfil),
        ("📓 Diario / Notas", ft.Colors.RED_400, lambda e: print("Ir a Diario")),
        ("🌐 Comunidad", ft.Colors.CYAN_300, lambda e: print("Ir a Comunidad")),
        ("🧰 Herramientas de Gestión", ft.Colors.GREEN_400, lambda e: print("Ir a Herramientas")),
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
    page.clean()
    page.add(
        ft.Column([
            ft.Text("👤 Perfil del Usuario", size=30, weight="bold"),
            ft.Text(f"Nombre: {usuario.get('nombre', 'No disponible')}"),
            ft.Text(f"Correo: {usuario.get('email', 'No disponible')}"),
            ft.Text(f"Monedas: {usuario.get('monedas', 0)}"),
            ft.ElevatedButton("Volver", on_click=lambda e: main_view(page, usuario))
        ],
        spacing=20,
        horizontal_alignment=ft.CrossAxisAlignment.START)
    )
    page.update()
