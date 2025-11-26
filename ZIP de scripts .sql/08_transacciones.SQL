/* 08_transacciones.sql */

USE clinica53;

-- Implementación de Transacciones con Retry
DROP PROCEDURE IF EXISTS sp_actualizar_datos_paciente;
DELIMITER //

CREATE PROCEDURE sp_actualizar_datos_paciente(
    IN p_id INT,
    IN p_grupo VARCHAR(5)
)
BEGIN
    DECLARE v_intento INT DEFAULT 0;
    DECLARE v_max INT DEFAULT 3;
    DECLARE v_hecho BOOLEAN DEFAULT FALSE;

    REPEAT
        SET v_intento = v_intento + 1;
        BEGIN
            -- Se usa el handler para atrapar errores (incluyendo Deadlock 1213)
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                -- Si hubo error, rollback y registro
                ROLLBACK;
                INSERT INTO log_transacciones(descripcion, intento, estado, codigo_error, mensaje)
                VALUES (CONCAT('Error en intento ', v_intento), v_intento, 'FALLÓ', SQLCODE(), 'Deadlock o error SQL');
            END;

            START TRANSACTION;

            -- Bloqueo explícito de filas para prevenir deadlocks
            -- SELECT 1 FROM Paciente WHERE id_paciente = p_id FOR UPDATE; 

            UPDATE Paciente
            SET grupo_sanguineo = p_grupo
            WHERE id_paciente = p_id;

            UPDATE HistoriaClinica
            SET observaciones = CONCAT('Grupo sanguíneo actualizado a ', p_grupo)
            WHERE id_paciente = p_id;

            COMMIT;

            -- Si se ejecutó correctamente, registrar éxito
            SET v_hecho = TRUE;
            INSERT INTO log_transacciones(descripcion, intento, estado)
            VALUES ('Actualización completada', v_intento, 'OK');
        END;

        -- Pequeño delay antes del retry
        IF v_hecho = FALSE THEN
            DO SLEEP(0.3 * v_intento);
        END IF;

    UNTIL v_hecho = TRUE OR v_intento >= v_max END REPEAT;

    -- Si falló todos los intentos, señalamos el error manualmente
    IF v_hecho = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transacción abortada por deadlock repetido';
    END IF;
END;
//

DELIMITER ;

-- Ejecutar la prueba
CALL sp_actualizar_datos_paciente(1, 'AB-');
SELECT * FROM log_transacciones ORDER BY id DESC LIMIT 5;