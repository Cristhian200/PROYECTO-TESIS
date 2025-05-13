from flask import render_template, request, redirect, url_for, flash, session
from db import actualizar_producto, actualizar_proveedor, agregar_producto, agregar_proveedor, eliminar_producto, eliminar_proveedor, login_usuario, obtener_producto_por_id, obtener_proveedor_por_id
from db import obtener_productos
from db import obtener_proveedores  # Asegúrate de tener esta función en db.py

def configurar_rutas(app):

    @app.route("/")
    def home():
        return redirect(url_for("login"))

    @app.route("/login", methods=["GET", "POST"])
    def login():
        if request.method == "POST":
            email = request.form.get("email")
            password = request.form.get("password")

            if login_usuario(email, password):
                session["usuario"] = email
                flash("Inicio de sesión exitoso", "success")
                return redirect(url_for("inventario"))  # Redirige al inventario
            else:
                flash("Credenciales incorrectas", "danger")
        
        return render_template("index.html")

    @app.route("/inventario")
    def inventario():
        if "usuario" not in session:
            return redirect(url_for("login"))

        productos = obtener_productos()
        return render_template("inventario.html", productos=productos)
    

    @app.route('/producto/nuevo', methods=['GET', 'POST'])
    def nuevo_producto():
        if request.method == 'POST':
            nombre = request.form['nombre'].strip()
            descripcion = request.form['descripcion'].strip()
            cantidad = request.form['cantidad']
            unidad = request.form['unidad']
            costo = request.form['costo']
            proveedor = request.form['proveedor']

            errores = []

            if not nombre:
                errores.append("El nombre del producto no puede estar vacío.")
            if not descripcion:
                errores.append("La descripción no puede estar vacía.")
            if not unidad:
                errores.append("Debe seleccionar una unidad de medida.")
            if not proveedor:
                errores.append("Debe seleccionar un proveedor.")

            try:
                cantidad = float(cantidad)
                if cantidad < 0:
                    errores.append("La cantidad no puede ser negativa.")
            except ValueError:
                errores.append("Cantidad inválida.")

            try:
                costo = float(costo)
                if costo < 0:
                    errores.append("El costo no puede ser negativo.")
            except ValueError:
                errores.append("Costo inválido.")

            if errores:
                for error in errores:
                    flash(error, 'danger')
                proveedores = obtener_proveedores()
                return render_template('formulario_producto.html', producto=None, proveedores=proveedores)

            agregar_producto(nombre, descripcion, cantidad, unidad, costo, proveedor)
            flash("Producto agregado exitosamente ✅", "success")
            return redirect(url_for('inventario'))

        proveedores = obtener_proveedores()
        return render_template('formulario_producto.html', producto=None, proveedores=proveedores)


    @app.route('/producto/editar/<int:id>', methods=['GET', 'POST'])
    def editar_producto(id):
        producto = obtener_producto_por_id(id)

        if request.method == 'POST':
            nombre = request.form['nombre'].strip()
            descripcion = request.form['descripcion'].strip()
            cantidad = request.form['cantidad']
            unidad = request.form['unidad']
            costo = request.form['costo']
            proveedor = request.form['proveedor']

            errores = []

            if not nombre:
                errores.append("El nombre del producto no puede estar vacío.")
            if not descripcion:
                errores.append("La descripción no puede estar vacía.")
            if not unidad:
                errores.append("Debe seleccionar una unidad de medida.")
            if not proveedor:
                errores.append("Debe seleccionar un proveedor.")

            try:
                cantidad = float(cantidad)
                if cantidad < 0:
                    errores.append("La cantidad no puede ser negativa.")
            except ValueError:
                errores.append("Cantidad inválida.")

            try:
                costo = float(costo)
                if costo < 0:
                    errores.append("El costo no puede ser negativo.")
            except ValueError:
                errores.append("Costo inválido.")

            if errores:
                for error in errores:
                    flash(error, 'danger')
                proveedores = obtener_proveedores()
                return render_template('formulario_producto.html', producto=producto, proveedores=proveedores)

            actualizar_producto(id, nombre, descripcion, cantidad, unidad, costo, proveedor)
            flash("Producto actualizado correctamente ✏️", "success")
            return redirect(url_for('inventario'))

        proveedores = obtener_proveedores()
        return render_template('formulario_producto.html', producto=producto, proveedores=proveedores)


    @app.route('/producto/eliminar/<int:id>', methods=['POST'])
    def eliminar(id):
        eliminar_producto(id)
        return redirect(url_for('inventario'))
    

    @app.route('/producto/guardar', methods=['POST'])
    def guardar_producto():
        nombre = request.form['nombre']
        descripcion = request.form['descripcion']
        cantidad = request.form['cantidad']
        unidad = request.form['unidad']
        costo = request.form['costo']
        proveedor = request.form['proveedor']
        agregar_producto(nombre, descripcion, cantidad, unidad, costo, proveedor)
        return redirect(url_for('inventario'))


    @app.route('/logout')
    def logout():
        session.clear()
        flash("Sesión cerrada correctamente", "info")
        return redirect(url_for('login'))

#PARTE DE PROVEEDORES CRUD
    @app.route('/proveedores')
    def proveedores():
        if "usuario" not in session:
            return redirect(url_for("login"))
        lista_proveedores = obtener_proveedores()
        return render_template('proveedores.html', proveedores=lista_proveedores)

    @app.route('/proveedor/nuevo', methods=['GET', 'POST'])
    def nuevo_proveedor():
        if request.method == 'POST':
            nombre = request.form['nombre']
            contacto = request.form['contacto']
            telefono = request.form['telefono']
            agregar_proveedor(nombre, contacto, telefono)
            return redirect(url_for('proveedores'))
        return render_template('formulario_proveedor.html', proveedor=None)

    @app.route('/proveedor/editar/<int:id>', methods=['GET', 'POST'])
    def editar_proveedor(id):
        if request.method == 'POST':
            nombre = request.form['nombre']
            contacto = request.form['contacto']
            telefono = request.form['telefono']
            actualizar_proveedor(id, nombre, contacto, telefono)
            return redirect(url_for('proveedores'))

        proveedor = obtener_proveedor_por_id(id)
        return render_template('formulario_proveedor.html', proveedor=proveedor)

    @app.route('/proveedor/eliminar/<int:id>', methods=['POST'])
    def eliminar_proveedor(id):
        eliminar_proveedor(id)
        return redirect(url_for('proveedores'))
    
    @app.route("/proveedores")
    def lista_proveedores():
        if "usuario" not in session:
            return redirect(url_for("login"))
        
        proveedores = obtener_proveedores()
        return render_template("proveedores.html", proveedores=proveedores)


    