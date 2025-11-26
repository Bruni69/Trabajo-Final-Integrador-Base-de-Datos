/* 05_consultas.sql */

USE clinica53;

-- Validación de Carga Masiva: Conteo de Registros (Repetido aquí por si es usado para verificar)
SELECT 'Pacientes' AS tabla, COUNT(*) AS cantidad FROM Paciente
UNION ALL
SELECT 'Historias Clínicas', COUNT(*) FROM HistoriaClinica;

-- Integridad referencial (Validación: debe retornar 0)
SELECT COUNT(*) FROM HistoriaClinica WHERE id_paciente NOT IN (SELECT id_paciente FROM Paciente);

-- Cardinalidad 1:1 respetada (Validación: debe retornar 0)
SELECT COUNT(*) FROM Paciente p LEFT JOIN HistoriaClinica h ON p.id_paciente = h.id_paciente WHERE h.id_historia IS NULL;

-- Grupos sanguíneos válidos
SELECT DISTINCT grupo_sanguineo FROM Paciente;

-- Consulta 1 – Datos Combinados de Pacientes e Historias Clínicas (JOIN)
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

-- Consulta 2 – Identificación de Pacientes Menores de 18 Años (JOIN + filtro)
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

-- Consulta 3 – Conteo de Pacientes por Grupo Sanguíneo (GROUP BY / HAVING)
SELECT
    grupo_sanguineo,
    COUNT(*) AS cantidad_pacientes
FROM Paciente
WHERE grupo_sanguineo IS NOT NULL
GROUP BY grupo_sanguineo
HAVING COUNT(*) > 25000
ORDER BY cantidad_pacientes DESC;

-- Consulta 4 – Pacientes de 80 años o más (Subconsulta)
SELECT 
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

-- Consulta DML: Visualización de Donantes Universales Elegibles (Requiere 06_vistas.sql)
SELECT * FROM vista_donantes_universales;

-- Llamada segura al procedimiento (Requiere 04_indices.sql)
CALL sp_buscar_paciente_por_dni('00123456');

-- Prueba anti-inyección (Requiere 04_indices.sql - debe fallar)
-- CALL sp_buscar_paciente_por_dni("'; DROP TABLE Paciente; --");