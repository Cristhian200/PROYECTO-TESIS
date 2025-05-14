# app/main.py
from . import create_app

# Crear la aplicación usando la función de `create_app` definida en `__init__.py`
app = create_app()

if __name__ == '__main__':
    app.run(debug=True)
