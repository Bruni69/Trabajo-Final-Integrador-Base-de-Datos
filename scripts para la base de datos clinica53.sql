---PRIMERA ETAPA.
/* Se crea base de datos. */

CREATE DATABASE clinica53;
USE clinica53;

/* Definición de Esquema: Tabla Paciente (PK, UNIQUE y CHECK de Dominio) */
 
USE clinica53;
CREATE TABLE Paciente (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    grupo_sanguineo VARCHAR(5) NULL,
    
    CONSTRAINT chk_grupo_sanguineo CHECK (
        grupo_sanguineo IS NULL 
        OR grupo_sanguineo IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')
    )
);

/* Definición de Esquema: Tabla HistoriaClinica (Implementación de Composición 1:1) */

CREATE TABLE HistoriaClinica (
    id_historia INT AUTO_INCREMENT PRIMARY KEY,
    nro_historia VARCHAR(20) NOT NULL UNIQUE,
    antecedentes TEXT NULL, 
    medicacion_actual TEXT NULL,
    observaciones TEXT NULL,
    
    id_paciente INT NOT NULL UNIQUE, 
    
    CONSTRAINT fk_historia_paciente
        FOREIGN KEY (id_paciente)
        REFERENCES Paciente (id_paciente)
        ON DELETE CASCADE
);

/* Triggers de Reglas de Negocio: Validación de Edad (insert). */

DELIMITER $$

CREATE TRIGGER validar_fecha_nacimiento
BEFORE
INSERT ON Paciente
FOR EACH
ROW
BEGIN
    DECLARE edad INT;

    IF NEW.fecha_nacimiento > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: la
fecha de nacimiento no puede ser futura.';
    END IF;

    SET edad =
TIMESTAMPDIFF(YEAR, NEW.fecha_nacimiento, CURDATE());

    IF edad > 120 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: la
edad no puede superar los 120 años.';
    END IF;
END$$

DELIMITER ;

/* Triggers de Reglas de Negocio: Validación de Edad (Update). */
DELIMITER $$

CREATE TRIGGER validar_fecha_nacimiento_update
BEFORE
UPDATE ON Paciente
FOR EACH
ROW
BEGIN
    DECLARE edad INT;

    IF NEW.fecha_nacimiento > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: la
fecha de nacimiento no puede ser futura.';
    END IF;

    SET edad = TIMESTAMPDIFF(YEAR,
NEW.fecha_nacimiento, CURDATE());

    IF edad > 120 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: la
edad no puede superar los 120 años.';
    END IF;
END$$

DELIMITER ;

/* Scripts de Inserción: Datos de Validación */

INSERT INTO Paciente (nombre, apellido, fecha_nacimiento, dni, grupo_sanguineo)
VALUES ('Juana', 'Paz', '1988-12-15', '40123456', 'AB-');

INSERT INTO Paciente (nombre, apellido, fecha_nacimiento, dni, grupo_sanguineo)
VALUES ('María', 'Gómez', '1985-04-12', '32145678', 'A+');

UPDATE Paciente
SET grupo_sanguineo = 'O-'
WHERE id_paciente = 1;

--Script de Inserción: Datos de Validación incorrectos.

INSERT INTO Paciente (nombre, apellido, fecha_nacimiento, dni, grupo_sanguineo)
VALUES ('Carlos', 'Fernández', '2030-05-10', '45988777', 'B+');

INSERT INTO Paciente (nombre, apellido, fecha_nacimiento, dni, grupo_sanguineo)
VALUES ('Juana', 'Pérez', '1890-01-15', '12345678', 'O+');

INSERT INTO Paciente (nombre, apellido, fecha_nacimiento, dni, grupo_sanguineo)
VALUES ('Roberto', 'Barto', '1980-12-15', '40123456', 'AB-');

--SEGUNDA ETAPA.
/* Carga Masiva de Datos: Población de Paciente en Dos Fases (2 x 100.000 Registros ) */
/* Primera fase */

USE clinica53;

INSERT INTO Paciente (nombre, apellido, dni, fecha_nacimiento, grupo_sanguineo)
SELECT
    CONCAT('Nombre', t1.i, t2.i, t3.i, t4.i, t5.i),
    CONCAT('Apellido', t1.i, t2.i, t3.i, t4.i, t5.i),
    LPAD(((t1.i*10000 + t2.i*1000 + t3.i*100 + t4.i*10 + t5.i)), 8, '0'),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*36500) DAY),
    ELT(FLOOR(RAND()*8)+1, 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')
FROM
    (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t1,
    (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t2,
    (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t3,
    (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t4,
    (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t5
LIMIT 100000;

/* Segunda fase */

USE clinica53;

INSERT INTO Paciente (nombre, apellido, dni, fecha_nacimiento, grupo_sanguineo)
SELECT
    CONCAT('NombreB', t1.i, t2.i, t3.i, t4.i, t5.i),
    CONCAT('ApellidoB', t1.i, t2.i, t3.i, t4.i, t5.i),
    LPAD(((t1.i*10000 + t2.i*1000 + t3.i*100 + t4.i*10 + t5.i + 100000)), 8, '0'),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*36500) DAY),
    ELT(FLOOR(RAND()*8)+1, 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')
FROM
    (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t1,
    (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t2,
    (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t3,
    (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t4,
    (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t5
LIMIT 100000;


/* Carga Masiva de 200.000 Historias Clínicas (Establecimiento de Relación Composición 1:1). */

USE clinica53;

INSERT INTO HistoriaClinica (nro_historia, antecedentes, medicacion_actual, observaciones, id_paciente)
SELECT
    CONCAT('HC', LPAD(id_paciente, 6, '0')),
    CONCAT('Antecedentes del paciente ', id_paciente),
    CONCAT('Medicación del paciente ', id_paciente),
    CONCAT('Observaciones del paciente ', id_paciente),
    id_paciente
FROM Paciente
ORDER BY id_paciente
LIMIT 200000;

/* Validación de Carga Masiva: Conteo de Registros */
USE clinica53;
SELECT 'Pacientes' AS tabla, COUNT(*) AS cantidad FROM Paciente
UNION ALL
SELECT 'Historias Clínicas', COUNT(*) FROM HistoriaClinica;

/* Integridad referencial */
SELECT COUNT(*) FROM HistoriaClinica WHERE id_paciente NOT IN (SELECT id_paciente FROM Paciente);

/* Cardinalidad 1:1 respetada */
SELECT COUNT(*) FROM Paciente p LEFT JOIN HistoriaClinica h ON p.id_paciente = h.id_paciente WHERE h.id_historia IS NULL;

/* Grupos sanguíneos válidos */
SELECT DISTINCT grupo_sanguineo FROM Paciente;

--ETAPA 3
/* Consulta 1 – Datos Combinados de Pacientes e Historias Clínicas (JOIN) */

USE clinica53;
SELECT
    p.id_paciente,
    CONCAT(p.nombre, ', ', p.apellido) AS nombre_completo,
    p.dni,
    p.grupo_sanguineo,
    h.nro_historia,
    h.medicacion_actual
FROM Paciente p
INNER JOIN HistoriaClinica h
ON p.id_paciente = h.id_paciente
ORDER BY p.id_paciente
LIMIT 20;

--Consulta Analítica: Identificación de Pacientes Menores de 18 Años.
USE clinica53;
SELECT
    p.id_paciente,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_completo,
    p.dni,
    TIMESTAMPDIFF(YEAR, p.fecha_nacimiento, CURDATE()) AS edad,
    p.grupo_sanguineo,
    h.nro_historia,
    h.antecedentes,
    h.medicacion_actual
FROM Paciente p
JOIN HistoriaClinica h
ON p.id_paciente = h.id_paciente
WHERE TIMESTAMPDIFF(YEAR, p.fecha_nacimiento, CURDATE()) < 18
ORDER BY edad ASC;

--Consulta de Agregación: Conteo de Pacientes por Grupo Sanguíneo

USE clinica53;
SELECT
    grupo_sanguineo,
    COUNT(*) AS cantidad_pacientes
FROM Paciente
WHERE grupo_sanguineo IS NOT NULL
GROUP BY grupo_sanguineo
ORDER BY cantidad_pacientes DESC;

--Consulta de Agregación: Grupos Sanguíneos Dominantes (Más de 25.000 Miembros)

USE clinica53;
SELECT
    grupo_sanguineo,
    COUNT(*) AS cantidad_pacientes
FROM Paciente
WHERE grupo_sanguineo IS NOT NULL
GROUP BY grupo_sanguineo
HAVING COUNT(*) > 25000;

--Consulta Analítica: Pacientes con Edad Superior al Promedio (Top 20).

USE clinica53;
SELECT
    id_paciente,
    nombre,
    apellido,
    TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) AS edad
FROM Paciente
WHERE TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) > (
    SELECT AVG(TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()))
    FROM Paciente
)
ORDER BY edad DESC
LIMIT 20;

--Creación de Vista: Identificación de Donantes Universales Elegibles

CREATE OR REPLACE VIEW Vista_Donantes_Universales AS
SELECT 
   p.id_paciente,
   CONCAT(p.nombre, ' ', p.apellido) AS nombre_completo,
   p.dni,
   p.grupo_sanguineo,
   TIMESTAMPDIFF(YEAR, p.fecha_nacimiento, CURDATE()) AS edad,
   h.nro_historia,
   h.antecedentes,
   h.medicacion_actual,
   h.observaciones
FROM Paciente p
JOIN HistoriaClinica h 
   ON p.id_paciente = h.id_paciente
WHERE 
   p.grupo_sanguineo = 'O-'
   AND TIMESTAMPDIFF(YEAR, p.fecha_nacimiento, CURDATE()) BETWEEN 18 AND
50; 

--Consulta DML: Visualización de Donantes Universales Elegibles.

USE clinica53;
SELECT * FROM Vistas_Donantes_Universales;

--ETAPA 4.
--Gestión de Seguridad: Creación de Usuario con Mínimos Privilegios.

USE clinica53;
CREATE USER IF NOT EXISTS 'app_user'@'localhost' IDENTIFIED BY '123456';
USE clinica53;
-- app_user necesita SELECT/INSERT/UPDATE limitados en paciente e historiaclinica
GRANT SELECT ON clinica53.paciente TO 'app_user'@'localhost';
GRANT SELECT ON clinica53.historiaclinica TO 'app_user'@'localhost';
GRANT INSERT ON clinica53.paciente TO 'app_user'@'localhost';
GRANT INSERT ON clinica53.historiaclinica TO 'app_user'@'localhost';
GRANT UPDATE ON clinica53.paciente TO 'app_user'@'localhost';
GRANT UPDATE ON clinica53.historiaclinica TO 'app_user'@'localhost';

--Prueba de Seguridad y Acceso Restringido (Auditoría de Privilegios y Fallo de DELETE)

USE clinica53;
SHOW GRANTS FOR 'app_user'@'localhost';
USE clinica53;
DELETE FROM historiaclinica WHERE id_historia = 1;

--Creación de Vista: Filtrado Máximo de Información Sensible de Pacientes

USE clinica53;
CREATE VIEW Vista_Pacientes_Publica AS
SELECT 
    id_paciente, 
    CONCAT(nombre, ' ', apellido) AS nombre_completo,
    grupo_sanguineo
FROM Paciente;

--Creación de Vista de Historial Resumido.

CREATE VIEW vista_historias_resumidas AS
SELECT 
    h.id_historia,
    p.id_paciente,
    CONCAT(p.nombre, '', p,apellido)AD¡Snombre_completo,,
    h.nro_historia,
    h.antecedentes
FROM HistoriaClinica h
JOIN Paciente p ON h.id_paciente = p.id_paciente;

--Otorgamiento de Permisos de Lectura.

GRANT SELECT ON clinica53.vista_pacientes_publico TO 'app_user'@'localhost';
GRANT SELECT ON clinica53.vista_historias_resumido TO 'app_user'@'localhost';

-- verificacion de permisosasignados.

USE clinica53;
SHOW GRANTS FOR 'app_user'@'localhost';

--Consulta de Lectura: Acceso a Datos Públicos de Pacientes.

USE clinica53;
SELECT * FROM Vista_Pacientes_Publico;

--Creación de Vista: Proyección de Nombres e Identificadores Básicos.

USE clinica53;
CREATE OR REPLACE VIEW Vista_Nombre_Apellido AS
SELECT
    p.id_paciente,
    p.nombre,
    p.apellido
FROM Paciente p;

--Consulta de Lectura: Acceso a Nombre y Apellido de Pacientes.

USE clinica53;
SELECT * FROM Vista_Nombre_Apellido;

--Prueba de Integridad: Violación Intencional de Restricción CHECK.

USE clinica53;
INSERT INTO Paciente (nombre, apellido, fecha_nacimiento, dni, grupo_sanguineo)
VALUES ('nombreX', 'apellidoX', '2000-01-01', '99999999', 'Z+');

--Prueba de Integridad: Violación Intencional de la Restricción UNIQUE (DNI Duplicado).

USE clinica53;
INSERT INTO Paciente (nombre, apellido, fecha_nacimiento, dni, grupo_sanguineo)
VALUES ('nombreX', 'apellidoX', '2000-01-01', '00031000', 'A+');

--Implementación de Seguridad: Procedimiento Almacenado Anti-Inyección SQL.

DELIMITER $$

CREATE PROCEDURE ObtenerHistoriaPorDNI(
    IN p_dni VARCHAR(20)
)
BEGIN
    SELECT
        P.nombre, 
        P.apellido, 
        H.nro_historia, 
        H.antecedentes,
        H.medicacion_actual
    FROM Paciente P
    JOIN HistoriaClinica H ON P.id_paciente = H.id_paciente
    WHERE P.dni = p_dni;
END$$

DELIMITER ;

USE clinica53;
válido
CALL ObtenerHistoriaPorDNI('40123456');

CALL ObtenerHistoriaPorDNI('40123456 OR 1=1; --'); 




