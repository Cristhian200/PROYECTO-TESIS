-- Creación de la base de datos (opcional, descomenta si necesitas crearla)
-- CREATE DATABASE zumba_lavanderia;

-- Conéctate a la base de datos antes de ejecutar el resto del script
-- Tabla Empresas
CREATE TABLE Empresas (
    empresa_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    fecha_creacion DATE
);

COMMENT ON TABLE Empresas IS 'Tabla de empresas matriz que gestionan las sucursales';

-- Tabla Sucursales
CREATE TABLE Sucursales (
    sucursal_id SERIAL PRIMARY KEY,
    empresa_id INTEGER NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    telefono VARCHAR(20),
    capacidad_maxima INTEGER,
    FOREIGN KEY (empresa_id) REFERENCES Empresas(empresa_id)
);

COMMENT ON TABLE Sucursales IS 'Ubicaciones físicas de las lavanderías';

-- Tabla Proveedores
CREATE TABLE Proveedores (
    proveedor_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    contacto_principal VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion VARCHAR(200),
    tipo_proveedor VARCHAR(10) NOT NULL CHECK (tipo_proveedor IN ('Químico', 'Equipo', 'Textil'))
);

COMMENT ON TABLE Proveedores IS 'Proveedores de materiales y equipos';

-- Tabla Empleados
CREATE TABLE Empleados (
    empleado_id SERIAL PRIMARY KEY,
    sucursal_id INTEGER NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    puesto VARCHAR(12) NOT NULL CHECK (puesto IN ('Operador', 'Supervisor', 'Administrativo')),
    fecha_contratacion DATE,
    salario DECIMAL(10,2),
    activo BOOLEAN,
    FOREIGN KEY (sucursal_id) REFERENCES Sucursales(sucursal_id)
);

COMMENT ON TABLE Empleados IS 'Personal que trabaja en las sucursales';

-- Tabla Materiales
CREATE TABLE Materiales (
    material_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('Caneca', 'Funda', 'Químico', 'Accesorio')),
    subtipo VARCHAR(50),
    capacidad DECIMAL(10,2),
    unidad_medida VARCHAR(10),
    material_padre_id INTEGER,
    proveedor_id INTEGER,
    stock_actual DECIMAL(10,2),
    stock_minimo DECIMAL(10,2),
    FOREIGN KEY (material_padre_id) REFERENCES Materiales(material_id),
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores(proveedor_id)
);

COMMENT ON TABLE Materiales IS 'Insumos para el proceso de lavandería';

-- Tabla Bodegas
CREATE TABLE Bodegas (
    bodega_id SERIAL PRIMARY KEY,
    sucursal_id INTEGER NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(100),
    capacidad DECIMAL(10,2),
    FOREIGN KEY (sucursal_id) REFERENCES Sucursales(sucursal_id)
);

COMMENT ON TABLE Bodegas IS 'Almacenes de materiales por sucursal';

-- Tabla Inventario
CREATE TABLE Inventario (
    inventario_id SERIAL PRIMARY KEY,
    material_id INTEGER NOT NULL,
    bodega_id INTEGER NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    fecha_actualizacion TIMESTAMP,
    FOREIGN KEY (material_id) REFERENCES Materiales(material_id),
    FOREIGN KEY (bodega_id) REFERENCES Bodegas(bodega_id)
);

COMMENT ON TABLE Inventario IS 'Existencia de materiales por bodega';

-- Tabla Ordenes_compra
CREATE TABLE Ordenes_compra (
    orden_compra_id SERIAL PRIMARY KEY,
    proveedor_id INTEGER NOT NULL,
    fecha_orden DATE NOT NULL,
    fecha_entrega_esperada DATE,
    estado VARCHAR(10) CHECK (estado IN ('Pendiente', 'Recibida', 'Cancelada')),
    total DECIMAL(12,2),
    notas TEXT,
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores(proveedor_id)
);

COMMENT ON TABLE Ordenes_compra IS 'Órdenes de compra a proveedores';

-- Tabla Detalles_ordenes_compra
CREATE TABLE Detalles_ordenes_compra (
    detalle_id SERIAL PRIMARY KEY,
    orden_compra_id INTEGER NOT NULL,
    material_id INTEGER NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2),
    FOREIGN KEY (orden_compra_id) REFERENCES Ordenes_compra(orden_compra_id),
    FOREIGN KEY (material_id) REFERENCES Materiales(material_id)
);

COMMENT ON TABLE Detalles_ordenes_compra IS 'Detalle de materiales en órdenes de compra';

-- Tabla Maquinarias
CREATE TABLE Maquinarias (
    maquinaria_id SERIAL PRIMARY KEY,
    sucursal_id INTEGER NOT NULL,
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('Lavadora', 'Secadora', 'Planchadora', 'Otro')),
    modelo VARCHAR(100),
    capacidad DECIMAL(10,2),
    fecha_adquisicion DATE,
    estado VARCHAR(12) CHECK (estado IN ('Operativa', 'Mantenimiento', 'Inactiva')),
    FOREIGN KEY (sucursal_id) REFERENCES Sucursales(sucursal_id)
);

COMMENT ON TABLE Maquinarias IS 'Equipos de lavandería por sucursal';

-- Tabla Clientes
CREATE TABLE Clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(8) NOT NULL CHECK (tipo IN ('Individual', 'Empresa')),
    cedula VARCHAR(10) NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    email VARCHAR(100),
    fecha_registro DATE
);



COMMENT ON TABLE Clientes IS 'Clientes que utilizan los servicios';

-- Tabla Estandares
CREATE TABLE Estandares (
    estandar_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    parametros JSON,
    tipo_servicio VARCHAR(10) NOT NULL CHECK (tipo_servicio IN ('Lavado', 'Planchado', 'Secado', 'Especial'))
);

COMMENT ON TABLE Estandares IS 'Estándares de calidad para los servicios';

-- Tabla Productos
CREATE TABLE Productos (
    producto_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    estandar_id INTEGER,
    precio_base DECIMAL(10,2),
    duracion_estimada INTEGER,
    FOREIGN KEY (estandar_id) REFERENCES Estandares(estandar_id)
);

COMMENT ON TABLE Productos IS 'Servicios ofrecidos por la lavandería';

-- Tabla Ordenes_produccion
CREATE TABLE Ordenes_produccion (
    orden_produccion_id SERIAL PRIMARY KEY,
    producto_id INTEGER NOT NULL,
    fecha_creacion TIMESTAMP,
    fecha_estimada_fin TIMESTAMP,
    estado VARCHAR(10) CHECK (estado IN ('Pendiente', 'En Proceso', 'Completada', 'Cancelada')),
    prioridad VARCHAR(7) CHECK (prioridad IN ('Baja', 'Normal', 'Alta', 'Urgente')),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id)
);

COMMENT ON TABLE Ordenes_produccion IS 'Órdenes para producción de servicios';

-- Tabla Orden_de_Trabajo
CREATE TABLE Orden_de_Trabajo (
    orden_trabajo_id SERIAL PRIMARY KEY,
    orden_produccion_id INTEGER,
    empleado_id INTEGER NOT NULL,
    cliente_id INTEGER NOT NULL,
    bodega_id INTEGER NOT NULL,
    fecha_creacion TIMESTAMP,
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    peso_total DECIMAL(10,2),
    observaciones TEXT,
    estado VARCHAR(10) CHECK (estado IN ('Pendiente', 'En Proceso', 'Completada', 'Cancelada')),
    FOREIGN KEY (orden_produccion_id) REFERENCES Ordenes_produccion(orden_produccion_id),
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id),
    FOREIGN KEY (bodega_id) REFERENCES Bodegas(bodega_id)
);

COMMENT ON TABLE Orden_de_Trabajo IS 'Órdenes específicas de lavado/planchado';

-- Tabla Lavadoras_asignadas
CREATE TABLE Lavadoras_asignadas (
    lavadora_asignada_id SERIAL PRIMARY KEY,
    orden_trabajo_id INTEGER NOT NULL,
    maquinaria_id INTEGER NOT NULL,
    fecha_asignacion TIMESTAMP,
    ciclo_lavado VARCHAR(50),
    duracion_minutos INTEGER,
    FOREIGN KEY (orden_trabajo_id) REFERENCES Orden_de_Trabajo(orden_trabajo_id),
    FOREIGN KEY (maquinaria_id) REFERENCES Maquinarias(maquinaria_id)
);

COMMENT ON TABLE Lavadoras_asignadas IS 'Asignación de lavadoras a órdenes de trabajo';

-- Tabla Materiales_usados
CREATE TABLE Materiales_usados (
    material_usado_id SERIAL PRIMARY KEY,
    orden_trabajo_id INTEGER NOT NULL,
    material_id INTEGER NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    fecha_registro TIMESTAMP,
    FOREIGN KEY (orden_trabajo_id) REFERENCES Orden_de_Trabajo(orden_trabajo_id),
    FOREIGN KEY (material_id) REFERENCES Materiales(material_id)
);

COMMENT ON TABLE Materiales_usados IS 'Materiales consumidos en cada orden de trabajo';

-- Tabla MaquinariaUso
CREATE TABLE MaquinariaUso (
    maquinaria_uso_id SERIAL PRIMARY KEY,
    maquinaria_id INTEGER NOT NULL,
    empleado_id INTEGER NOT NULL,
    orden_trabajo_id INTEGER,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP,
    tipo_uso VARCHAR(12) NOT NULL CHECK (tipo_uso IN ('Lavado', 'Secado', 'Mantenimiento', 'Otro')),
    consumo_energia DECIMAL(10,2),
    observaciones TEXT,
    FOREIGN KEY (maquinaria_id) REFERENCES Maquinarias(maquinaria_id),
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id),
    FOREIGN KEY (orden_trabajo_id) REFERENCES Orden_de_Trabajo(orden_trabajo_id)
);

COMMENT ON TABLE MaquinariaUso IS 'Registro de uso y mantenimiento de maquinaria';

-- Tabla Materiales_MaquinariaUso
CREATE TABLE Materiales_MaquinariaUso (
    material_uso_id SERIAL PRIMARY KEY,
    maquinaria_uso_id INTEGER NOT NULL,
    material_id INTEGER NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (maquinaria_uso_id) REFERENCES MaquinariaUso(maquinaria_uso_id),
    FOREIGN KEY (material_id) REFERENCES Materiales(material_id)
);

COMMENT ON TABLE Materiales_MaquinariaUso IS 'Materiales usados en mantenimiento/operación de maquinaria';

-- Tabla Facturas
CREATE TABLE Facturas (
    factura_id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    fecha_emision DATE NOT NULL,
    fecha_vencimiento DATE,
    subtotal DECIMAL(12,2) NOT NULL,
    impuestos DECIMAL(10,2),
    total DECIMAL(12,2),
    estado VARCHAR(10) CHECK (estado IN ('Pendiente', 'Pagada', 'Cancelada')),
    metodo_pago VARCHAR(12) CHECK (metodo_pago IN ('Efectivo', 'Tarjeta', 'Transferencia', 'Otro')),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);

COMMENT ON TABLE Facturas IS 'Facturas a clientes por servicios';

-- Tabla Detalles_factura
CREATE TABLE Detalles_factura (
    detalle_id SERIAL PRIMARY KEY,
    factura_id INTEGER NOT NULL,
    producto_id INTEGER,
    descripcion VARCHAR(200),
    cantidad INTEGER,
    precio_unitario DECIMAL(10,2),
    subtotal DECIMAL(12,2),
    FOREIGN KEY (factura_id) REFERENCES Facturas(factura_id),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id)
);

COMMENT ON TABLE Detalles_factura IS 'Detalle de servicios en facturas';

-- Tabla Transacciones
CREATE TABLE Transacciones (
    transaccion_id SERIAL PRIMARY KEY,
    tipo VARCHAR(7) NOT NULL CHECK (tipo IN ('Ingreso', 'Egreso', 'Ajuste')),
    fecha TIMESTAMP,
    monto DECIMAL(12,2) NOT NULL,
    descripcion VARCHAR(200),
    referencia_id INTEGER,
    tipo_referencia VARCHAR(12) CHECK (tipo_referencia IN ('Factura', 'OrdenCompra', 'Mantenimiento', 'Otro'))
);

COMMENT ON TABLE Transacciones IS 'Registro de movimientos financieros';

-- Tabla Orden_Transaccion
CREATE TABLE Orden_Transaccion (
    orden_transaccion_id SERIAL PRIMARY KEY,
    orden_trabajo_id INTEGER NOT NULL,
    transaccion_id INTEGER NOT NULL,
    tipo VARCHAR(6) NOT NULL CHECK (tipo IN ('Costo', 'Pago', 'Ajuste')),
    FOREIGN KEY (orden_trabajo_id) REFERENCES Orden_de_Trabajo(orden_trabajo_id),
    FOREIGN KEY (transaccion_id) REFERENCES Transacciones(transaccion_id)
);

COMMENT ON TABLE Orden_Transaccion IS 'Relación entre órdenes de trabajo y transacciones';

CREATE TABLE Usuarios (
    usuario_id SERIAL PRIMARY KEY,
    empleado_id INTEGER NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    contraseña_hash VARCHAR(128) NOT NULL,
    es_administrador BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    token_recuperacion VARCHAR(100),
    expiracion_token TIMESTAMP,
    FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id) ON DELETE CASCADE
);

COMMENT ON TABLE Usuarios IS 'Tabla para el sistema de autenticación de usuarios asociados a empleados';



/*CAMBIOS EN TABLAS 
ALTER TABLE Empleados
ADD COLUMN email VARCHAR(120) UNIQUE,
ADD COLUMN telefono_contacto VARCHAR(20),
ADD COLUMN fecha_nacimiento DATE;

ALTER TABLE Empleados
ALTER COLUMN puesto TYPE VARCHAR(20);

-- Actualizar la constraint CHECK para mantener la validación
ALTER TABLE Empleados
DROP CONSTRAINT IF EXISTS empleados_puesto_check;

ALTER TABLE Empleados
ADD CONSTRAINT empleados_puesto_check 
CHECK (puesto IN ('Operador', 'Supervisor', 'Administrativo', 'Gerente', 'Asistente'));*/

/*INSERT
INSERT INTO Empresas (nombre, direccion, telefono, fecha_creacion)
VALUES 
('Zumba Lavandería', 'Av. Galo Plaza Lasso, Quito, Ecuador', '02347281', '2025-03-15');


INSERT INTO Sucursales (empresa_id, nombre, direccion, telefono, capacidad_maxima)
VALUES
(1, 'Zumba Lavandería', 'Av. Galo Plaza Lasso, Quito, Ecuador', '02347281', 10);

-- Primero insertar el empleado
INSERT INTO Empleados (sucursal_id, nombre, apellido, puesto, fecha_contratacion, salario, activo, email)
VALUES (1, 'Cristhian', 'Proaño', 'Administrativo', '2023-01-15', 2500.00, TRUE, 'cris@hotmail.com');


INSERT INTO Usuarios (
    empleado_id, 
    email, 
    nombre_usuario, 
    contraseña_hash, 
    es_administrador, 
    activo
) VALUES (
    (SELECT empleado_id FROM Empleados WHERE email = 'cris@hotmail.com'),
    'cris@hotmail.com',  -- Cambiado para que coincida con el email del empleado
    'cproano',
    '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
    TRUE,
    TRUE
);

INSERT INTO Empresas (nombre, direccion, telefono, fecha_creacion)
VALUES 
('Zumba Lavandería', 'Av. Galo Plaza Lasso, Quito, Ecuador', '02347281', '2025-03-15');


INSERT INTO Sucursales (empresa_id, nombre, direccion, telefono, capacidad_maxima)
VALUES
(1, 'Zumba Lavandería', 'Av. Galo Plaza Lasso, Quito, Ecuador', '02347281', 10);
*/
