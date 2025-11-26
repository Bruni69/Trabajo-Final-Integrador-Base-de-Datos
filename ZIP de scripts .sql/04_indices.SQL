/* 04_indices.sql */

USE clinica53;

-- Triggers de Reglas de Negocio: Validación de Edad (INSERT)
DROP TRIGGER IF EXISTS validar_fecha_nacimiento;
DELIMITER $$

CREATE TRIGGER validar_fecha_nacimiento
BEFORE INSERT ON Paciente
FOR EACH ROW
BEGIN
    DECLARE edad INT;

    IF NEW.fecha_nacimiento > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: la fecha de nacimiento no puede ser futura.';
    END IF;

    SET edad = TIMESTAMPDIFF(YEAR, NEW.fecha_nacimiento, CURDATE());

    IF edad > 120 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: la edad no puede superar los 120 años.';
    END IF;
END$$

DELIMITER ;

-- Triggers de Reglas de Negocio: Validación de Edad (UPDATE)
DROP TRIGGER IF EXISTS validar_fecha_nacimiento_update;
DELIMITER $$

CREATE TRIGGER validar_fecha_nacimiento_update
BEFORE UPDATE ON Paciente
FOR EACH ROW
BEGIN
    DECLARE edad INT;

    IF NEW.fecha_nacimiento > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: la fecha de nacimiento no puede ser futura.';
    END IF;

    SET edad = TIMESTAMPDIFF(YEAR, NEW.fecha_nacimiento, CURDATE());

    IF edad > 120 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: la edad no puede superar los 120 años.';
    END IF;
END$$

DELIMITER ;

-- Implementación de Seguridad: Procedimiento Almacenado Anti-Inyección SQL.
DROP PROCEDURE IF EXISTS sp_buscar_paciente_por_dni;
DELIMITER $$

CREATE PROCEDURE sp_buscar_paciente_por_dni(IN dni_busqueda VARCHAR(20))
BEGIN
    SELECT 
        id_paciente,
        CONCAT(nombre, ' ', apellido) AS nombre_completo,
        fecha_nacimiento,
        grupo_sanguineo
    FROM Paciente
    WHERE dni = dni_busqueda;
END$$

DELIMITER ;

-- Creación de Índices para optimización

-- Índice para rango (Consulta de Edad/Fecha de Nacimiento)
DROP INDEX IF EXISTS idx_paciente_fecha_nac ON Paciente;
CREATE INDEX idx_paciente_fecha_nac ON Paciente(fecha_nacimiento);

-- Índice para JOIN (FK en HistoriaClinica)
DROP INDEX IF EXISTS idx_historia_fk ON HistoriaClinica;
CREATE INDEX idx_historia_fk ON HistoriaClinica(id_paciente);