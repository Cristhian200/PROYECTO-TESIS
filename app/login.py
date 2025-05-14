from flask_login import LoginManager
from .models import Usuario

login_manager = LoginManager()
login_manager.login_view = 'login'  # Redirige a esta vista si no está logueado

# Esto le dice a Flask-Login cómo cargar un usuario desde el ID almacenado en sesión
@login_manager.user_loader
def load_user(user_id):
    return Usuario.query.get(int(user_id))
