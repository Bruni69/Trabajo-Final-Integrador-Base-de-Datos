/* 05_explain.sql */

USE clinica53;

-- Igualdad sin indice (DNI es UNIQUE, usa el índice implícito, se fuerza a ignorar)
EXPLAIN SELECT 
    id_paciente, nombre, apellido, dni, grupo_sanguineo
FROM Paciente IGNORE INDEX (dni)
WHERE dni = '00123456';

-- Igualdad con indice (DNI usa el índice UNIQUE)
EXPLAIN SELECT 
	id_paciente, nombre, apellido, dni, grupo_sanguineo 
FROM Paciente 
WHERE dni = '00123456';

-- Rango sin índice de fecha_nacimiento
EXPLAIN SELECT 
    id_paciente,
    nombre,
    apellido,
    dni,
    TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) AS edad
FROM Paciente
WHERE id_paciente IN (
    SELECT id_paciente
    FROM Paciente
    WHERE TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) >= 80
)
ORDER BY edad ASC;

-- Rango con índice (idx_paciente_fecha_nac)
EXPLAIN SELECT 
    id_paciente,
    nombre,
    apellido,
    dni,
    TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) AS edad
FROM Paciente
WHERE fecha_nacimiento <= DATE_SUB(CURDATE(), INTERVAL 80 YEAR)
ORDER BY edad ASC;

-- JOIN sin índice (idx_historia_fk)
EXPLAIN SELECT
    p.id_paciente,
    CONCAT(p.nombre, ', ', p.apellido) AS nombre_completo,
    p.dni,
    p.grupo_sanguineo,
    h.nro_historia,
    h.medicacion_actual
FROM Paciente p
INNER JOIN HistoriaClinica h IGNORE INDEX (idx_historia_fk)
    ON p.id_paciente = h.id_paciente
ORDER BY p.id_paciente;

-- JOIN con índice (idx_historia_fk)
EXPLAIN SELECT
    p.id_paciente,
    CONCAT(p.nombre, ', ', p.apellido) AS nombre_completo,
    p.dni,
    p.grupo_sanguineo,
    h.nro_historia,
    h.medicacion_actual
FROM Paciente p
INNER JOIN HistoriaClinica h
    ON p.id_paciente = h.id_paciente
ORDER BY p.id_paciente;