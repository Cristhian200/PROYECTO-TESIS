print(">>> empleados.py SE ESTÁ IMPORTANDO <<<")

from flask import Blueprint, render_template, request, redirect, url_for, flash
from .models import db, Empleado
from flask_login import login_required

bp_empleados = Blueprint('empleados', __name__, url_prefix='/empleados')

@bp_empleados.route('/')
@login_required
def lista():
    empleados = Empleado.query.all()
    return render_template('empleados/lista.html', empleados=empleados)

@bp_empleados.route('/nuevo', methods=['GET', 'POST'])
@login_required
def nuevo():
    if request.method == 'POST':
        # Asignar sucursal_id automáticamente (secuencial)
        last_sucursal = db.session.query(db.func.max(Empleado.sucursal_id)).scalar()
        next_sucursal_id = (last_sucursal or 0) + 1

        empleado = Empleado(
            sucursal_id=next_sucursal_id,
            nombre=request.form['nombre'],
            apellido=request.form['apellido'],
            puesto=request.form['puesto'],
            fecha_contratacion=request.form['fecha_contratacion'],
            salario=request.form['salario'],
            activo='activo' in request.form
        )
        db.session.add(empleado)
        db.session.commit()
        flash('Empleado creado exitosamente.')
        return redirect(url_for('empleados.lista'))
    return render_template('empleados/nuevo.html')

@bp_empleados.route('/editar/<int:empleado_id>', methods=['GET', 'POST'])
@login_required
def editar(empleado_id):
    empleado = Empleado.query.get_or_404(empleado_id)
    if request.method == 'POST':
        # No modificar sucursal_id
        empleado.nombre = request.form['nombre']
        empleado.apellido = request.form['apellido']
        empleado.puesto = request.form['puesto']
        empleado.fecha_contratacion = request.form['fecha_contratacion']
        empleado.salario = request.form['salario']
        empleado.activo = 'activo' in request.form
        db.session.commit()
        flash('Empleado actualizado.')
        return redirect(url_for('empleados.lista'))
    return render_template('empleados/editar.html', empleado=empleado)

@bp_empleados.route('/eliminar/<int:empleado_id>', methods=['POST'])
@login_required
def eliminar(empleado_id):
    empleado = Empleado.query.get_or_404(empleado_id)
    db.session.delete(empleado)
    db.session.commit()
    flash('Empleado eliminado.')
    return redirect(url_for('empleados.lista'))