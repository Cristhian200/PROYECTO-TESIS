# db.py
import psycopg2

def conectar():
    try:
        conexion = psycopg2.connect(
            host="localhost",
            port=5432,
            database="ZUMBA_LAVANDERIA_BDD",
            user="postgres",
            password="cris"
        )
        return conexion
    except Exception as e:
        print(f"Error de conexión: {e}")
        return None