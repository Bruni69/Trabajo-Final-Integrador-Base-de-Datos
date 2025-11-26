/* 09_concurrencia_guiada.sql */

USE clinica53;

-- ** IMPORTANTE: ESTE SCRIPT DEBE EJECUTARSE EN DOS O MÁS SESIONES SIMULTÁNEAS **

-- Comprobar IDs de prueba (debe retornar los IDs 1 y 2)
SELECT id_paciente FROM Paciente ORDER BY id_paciente LIMIT 2;  

-- Reiniciar el campo grupo_sanguineo para las pruebas de aislamiento
UPDATE Paciente SET grupo_sanguineo = 'A+' WHERE id_paciente = 1;


-- =========================================================================
-- PRUEBA DE DEADLOCK
-- =========================================================================

-- ** SESIÓN A **
-- 1. Iniciar la transacción A
-- 2. Ejecutar la primera línea (Bloqueo P1)
-- 3. Cambiar a SESIÓN B, ejecutar su primera línea (Bloqueo H2)
-- 4. Volver a SESIÓN A, ejecutar la segunda línea (Intenta bloquear H2 -> DEADLOCK)

/* SECCIÓN A (Ejecutar línea por línea) */
USE clinica53;
START TRANSACTION;
-- 1) Bloquea Paciente p1
SELECT * FROM Paciente WHERE id_paciente = 1 FOR UPDATE;
-- Pausar la transacción durante 10 segundos 
DO SLEEP(10);
-- 2) Aquí se producirá el deadlock
SELECT * FROM HistoriaClinica WHERE id_paciente = 2 FOR UPDATE;


-- ** SESIÓN B **
/* SECCIÓN B (Ejecutar línea por línea) */
USE clinica53;
START TRANSACTION;
-- 1) Bloquea HistoriaClinica p2
SELECT * FROM HistoriaClinica WHERE id_paciente = 2 FOR UPDATE;
-- Pausar la transacción durante 10 segundos 
DO SLEEP(10);
-- 2) (Intenta bloquear Paciente p1)
SELECT * FROM Paciente WHERE id_paciente = 1 FOR UPDATE;

-- Para verificar el estado del Deadlock (en una tercera sesión)
SHOW ENGINE INNODB STATUS;


-- =========================================================================
-- PRUEBA DE NIVELES DE AISLAMIENTO
-- =========================================================================

-- Caso 1 – Nivel READ COMMITTED (Permite lecturas sucias/cambiantes)

-- ** SESIÓN A (READ COMMITTED) **
USE clinica53;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT grupo_sanguineo FROM Paciente WHERE id_paciente = 1;  -- Muestra 'A+' (Valor inicial)
-- No cerrar todavía la transacción
DO SLEEP(5); -- Esperar a que Sesión B haga su COMMIT

-- Ejecutar Seccion b y luego esta
SELECT grupo_sanguineo FROM Paciente WHERE id_paciente = 1;  -- Muestra 'B-' (Lectura sucia)
COMMIT;

-- ** SESIÓN B **
USE clinica53;
START TRANSACTION;
UPDATE Paciente SET grupo_sanguineo = 'B-' WHERE id_paciente = 1;
COMMIT;


-- Caso 2 – Nivel REPEATABLE READ (Evita lecturas sucias/cambiantes)
UPDATE Paciente SET grupo_sanguineo = 'A+' WHERE id_paciente = 1; -- Reiniciar valor

-- ** SESIÓN A (REPEATABLE READ) **
USE clinica53;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT grupo_sanguineo FROM Paciente WHERE id_paciente = 1;  -- Muestra 'A+' (Valor inicial)
-- No cerrar todavía
DO SLEEP(5); -- Esperar a que Sesión B haga su COMMIT

-- Ejecutar Seccion b y luego esta
SELECT grupo_sanguineo FROM Paciente WHERE id_paciente = 1;  -- Sigue viendo 'A+' (Bloquea la lectura sucia)
COMMIT;

-- ** SESIÓN B **
USE clinica53;
START TRANSACTION;
UPDATE Paciente SET grupo_sanguineo = 'B-' WHERE id_paciente = 1;
COMMIT;