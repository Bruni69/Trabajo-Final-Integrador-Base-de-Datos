/* 07_seguridad.sql */

USE clinica53;

-- Gestión de Seguridad: Creación de Usuario con Mínimos Privilegios.
-- DROP USER IF EXISTS 'app_user'@'localhost'; -- No está en el código original, pero es necesario para la idempotencia.
CREATE USER IF NOT EXISTS 'app_user'@'localhost' IDENTIFIED BY '123456';

-- Otorgamiento de Permisos en Tablas
GRANT SELECT, INSERT, UPDATE 
ON clinica53.paciente TO 'app_user'@'localhost';
GRANT SELECT, INSERT, UPDATE 
ON clinica53.historiaclinica TO 'app_user'@'localhost';

-- Otorgamiento de Permisos en Vistas (Lectura)
GRANT SELECT ON clinica53.vista_pacientes_publica TO 'app_user'@'localhost';
GRANT SELECT ON clinica53.vista_historial_resumido TO 'app_user'@'localhost';

-- Verificar privilegios
SHOW GRANTS FOR 'app_user'@'localhost';

-- Prueba de Seguridad y Acceso Restringido (Fallo de DELETE) 
-- Este comando debe ejecutarse bajo el usuario 'app_user'@'localhost' para validar la restricción.
-- DELETE FROM historiaclinica WHERE id = 1;

-- Pruebas de Integridad (Estos comandos deben fallar)
-- Prueba de Integridad: Violación intencional de integridad referencial
-- INSERT INTO HistoriaClinica (nro_historia, antecedentes, medicacion_actual, observaciones, id_paciente) VALUES ('HC999999', 'Prueba', 'N/A', 'Paciente inexistente', 999999);

-- Prueba de Integridad: Violación Intencional de Restricción CHECK.
-- INSERT INTO Paciente (nombre, apellido, fecha_nacimiento, dni, grupo_sanguineo) VALUES ('Juan', 'Pérez', '1980-05-12', '99999999', 'XZ');