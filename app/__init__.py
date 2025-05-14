from flask import Flask
from flask_login import LoginManager
from .models import db, Usuario
from .routes import bp as main_bp
from .auth import bp as auth_bp
from .empleados import bp_empleados

print(">>> Importando main_bp")
print(">>> Importando auth_bp")
print(">>> Importando bp_empleados")

def create_app():
    app = Flask(__name__)

    # Configuración
    app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:cris@localhost:5432/CONTROL_LAVANDERIA'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['SECRET_KEY'] = 'ProyectoLavanderia'

    # Inicializar SQLAlchemy
    db.init_app(app)

    with app.app_context():
        db.create_all()

    # Configurar Login Manager
    login_manager = LoginManager()
    login_manager.login_view = 'auth.login'
    login_manager.init_app(app)

    @login_manager.user_loader
    def load_user(user_id):
        return Usuario.query.get(int(user_id))

    # Registrar blueprints
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp)
    app.register_blueprint(bp_empleados)
    return app