# main.py

from flask import Flask
from app.routes import configurar_rutas

app = Flask(__name__)
app.secret_key = "clave_secreta_zumba"  # Necesario para sesiones y flashes

configurar_rutas(app)

if __name__ == "__main__":
    app.run(debug=True)
