from flask import Blueprint, render_template
from flask_login import login_required, current_user

bp = Blueprint('main', __name__)

@bp.route('/')
def index():
    return render_template('login.html')

@bp.route('/menu_principal')
@login_required
def menu_principal():
    return render_template('menu_principal.html', usuario=current_user)