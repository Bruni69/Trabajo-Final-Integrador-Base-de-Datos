use clinica53;
-- Crear tabla de registro de intentos para concurrencia/transacciones
DROP TABLE IF EXISTS log_transacciones;
CREATE TABLE IF NOT EXISTS log_transacciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion VARCHAR(100),
    intento INT,
    estado VARCHAR(20),
    codigo_error INT,
    mensaje TEXT
);