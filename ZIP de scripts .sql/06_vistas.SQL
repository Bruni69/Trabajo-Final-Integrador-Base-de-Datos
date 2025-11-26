/* 06_vistas.sql */

USE clinica53;

-- Vista 1: Información general de pacientes (sin datos sensibles)
DROP VIEW IF EXISTS vista_pacientes_publica;
CREATE OR REPLACE VIEW vista_pacientes_publica AS
SELECT 
    id_paciente,
    CONCAT(nombre, ' ', apellido) AS nombre_completo,
    grupo_sanguineo
FROM Paciente;

-- Vista 2: Resumen clínico sin observaciones ni medicación
DROP VIEW IF EXISTS vista_historial_resumido;
CREATE OR REPLACE VIEW vista_historial_resumido AS
SELECT 
    h.id_historia,
    p.id_paciente,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_completo,
    h.nro_historia,
    h.antecedentes
FROM HistoriaClinica h
JOIN Paciente p ON h.id_paciente = p.id_paciente;

-- Creación de Vista: Identificación de Donantes Universales Elegibles
DROP VIEW IF EXISTS Vista_Donantes_Universales;
CREATE OR REPLACE VIEW Vista_Donantes_Universales AS
SELECT 
    p.id_paciente,
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_completo,
    p.dni,
    p.grupo_sanguineo,
    TIMESTAMPDIFF(YEAR, p.fecha_nacimiento, CURDATE()) AS edad
FROM Paciente p
JOIN HistoriaClinica h 
    ON p.id_paciente = h.id_paciente
WHERE 
    p.grupo_sanguineo = 'O-'
    AND TIMESTAMPDIFF(YEAR, p.fecha_nacimiento, CURDATE()) BETWEEN 18 AND 50;