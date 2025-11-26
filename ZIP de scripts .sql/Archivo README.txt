# Proyecto de Base de Datos - Clínica Médica

## Versión del Motor
MySQL 8.0+ / MariaDB 10.x

## Scripts y Orden de Ejecución

Todos los scripts son **idempotentes** (usan DROP/CREATE IF EXISTS).

1.  **01_esquema.sql:** Creación de la base de datos (DROP/CREATE DATABASE) y las tablas (PK, FK, UNIQUE, CHECK).
2.  **02_catalogos.sql:** Creación de tablas de apoyo (e.g., log_transacciones).
3.  **03_carga_masiva.sql:** Inserción de datos iniciales y la carga masiva (200.000 registros).
4.  **04_indices.sql:** Creación de TRIGGERS, Stored Procedure (sp_buscar_paciente_por_dni) e Índices (IDX).
5.  **05_consultas.sql:** Ejecución de todas las consultas DML (JOIN, Subconsultas, GROUP BY).
6.  **05_explain.sql:** Análisis de las consultas con EXPLAIN para demostrar la optimización de índices.
7.  **06_vistas.sql:** Creación de las VISTAS (para simplificación y seguridad).
8.  **07_seguridad.sql:** Creación de usuario 'app_user' y asignación de privilegios mínimos (GRANT/REVOKE). Incluye pruebas de seguridad (que deben fallar).
9.  **08_transacciones.sql:** Implementación del Stored Procedure sp_actualizar_datos_paciente con lógica de retry para manejo de Deadlocks.
10. **09_concurrencia_guiada.sql:** Script interactivo para probar los escenarios de Deadlock y los Niveles de Aislamiento (Requiere 2+ sesiones de MySQL).