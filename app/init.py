from flask import Flask

app = Flask(__name__)

# Importa las rutas
from app.routes import *