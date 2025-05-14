select * from empleados
select * from usuarios


-- Primero renombramos la columna y cambiamos su tipo
ALTER TABLE Usuarios 
    RENAME COLUMN contraseña_hash TO contraseña;

-- Luego modificamos el tipo con un largo más seguro
ALTER TABLE Usuarios 
    ALTER COLUMN contraseña TYPE VARCHAR(50);

-- Si necesitas insertar usuarios de prueba
INSERT INTO Usuarios (
    empleado_id,
    email,
    nombre_usuario,
    contraseña,
    es_administrador,
    activo
) VALUES (
    1,  -- Asegúrate que este empleado_id existe
    'crisprueba@hotmail.com',
    'cristhian',
    'Tonsupa2006@',
    TRUE,
    TRUE
);