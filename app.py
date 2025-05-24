import flet as ft
from login import validar_login
from views import main_view 

def main(page: ft.Page):
    page.title = "App Liz"
    page.window_width = 400 
    page.window_height = 700  
    page.window_resizable = False  
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"

    from login import login_view
    page.add(login_view(page))


ft.app(target=main, view=ft.AppView.FLET_APP)

