from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from flask_login import UserMixin

db = SQLAlchemy()

# ─────────────────────────────
# MODELO SUCURSAL
# ─────────────────────────────
class Sucursal(db.Model):
    __tablename__ = 'sucursales'

    sucursal_id = db.Column(db.Integer, primary_key=True)
    empresa_id = db.Column(db.Integer, nullable=False)
    nombre = db.Column(db.String(100), nullable=False)
    direccion = db.Column(db.String(200), nullable=False)
    telefono = db.Column(db.String(20))
    capacidad_maxima = db.Column(db.Integer)

    empleados = db.relationship('Empleado', backref='sucursal', lazy=True)

# ─────────────────────────────
# MODELO EMPLEADO
# ─────────────────────────────
class Empleado(db.Model):
    __tablename__ = 'empleados'
    empleado_id = db.Column(db.Integer, primary_key=True)
    sucursal_id = db.Column(db.Integer, db.ForeignKey('sucursales.sucursal_id'), nullable=False)
    nombre = db.Column(db.String(100), nullable=False)
    apellido = db.Column(db.String(100), nullable=False)
    puesto = db.Column(db.String(12), nullable=False)
    fecha_contratacion = db.Column(db.Date)
    salario = db.Column(db.Numeric(10,2))
    activo = db.Column(db.Boolean)

# ─────────────────────────────
# MODELO USUARIO (para login)
# ─────────────────────────────
class Usuario(UserMixin, db.Model):
    __tablename__ = 'usuarios'  # Nombre correcto de la tabla
    
    usuario_id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    contraseña = db.Column(db.String(50), nullable=False)
    empleado_id = db.Column(db.Integer, db.ForeignKey('Empleados.empleado_id'), nullable=False)
    nombre_usuario = db.Column(db.String(50), nullable=False, unique=True)
    es_administrador = db.Column(db.Boolean, default=False)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    ultimo_acceso = db.Column(db.DateTime)
    activo = db.Column(db.Boolean, default=True)
    token_recuperacion = db.Column(db.String(100))
    expiracion_token = db.Column(db.DateTime)

    def check_password(self, password):
        return password == self.contraseña

    def get_id(self):
        return str(self.usuario_id)
