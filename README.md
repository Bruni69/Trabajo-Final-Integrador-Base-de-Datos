# 🏥 TFI - Sistema de Gestión de Clínica (Base de Datos Relacional)

## 📜 Descripción del Proyecto

Este proyecto es el **Trabajo Final Integrador (TFI)** para la materia **Bases de Datos I**. Su principal objetivo es diseñar, implementar y administrar un esquema de base de datos relacional 
para un sistema de gestión de pacientes e historias clínicas (`clinica53`).

Se aplican y demuestran los conceptos clave de bases de datos relacionales:

* **Modelado:** Entidades `Paciente` e `HistoriaClinica` con una relación **1:1**.
* **Integridad:** Definición de *Constraints* (UNIQUE, CHECK), Claves Foráneas y *Triggers*.
* **Seguridad:** Creación de Vistas y Procedimientos Almacenados seguros.
* **Gestión:** Implementación de la **Baja Lógica** (`eliminado` booleano) para la gestión de registros.

## ⚙️ Estructura de la Base de Datos

El diseño se centra en dos entidades principales que se correlacionan directamente con el modelo de objetos de la aplicación:

| Entidad | Clave Primaria | Relación | Notas de Integridad |
| :--- | :--- | :--- | :--- |
| **`Paciente`** | `id_paciente` | N/A | `dni` es **UNIQUE**. `grupo_sanguineo` usa una restricción **CHECK** para validar dominios (A+, O-, etc.). |
| **`HistoriaClinica`** | `id_historia` | FK a `Paciente` | **Relación 1:1** impuesta por la restricción **UNIQUE** en `id_paciente`. |

## 🔒 Componentes de Integridad y Seguridad (Scripts SQL)

El archivo **`scripts para la base de datos clinica53.sql`** no solo crea las tablas, sino que también implementa la lógica avanzada de la base de datos:

| Componente | Objetivo |
| **Triggers** | Aseguran que se cumplan las reglas de negocio complejas (Ej: Validación de edad al insertar un paciente). |
| **Vistas** | Implementan seguridad al proyectar solo información necesaria para ciertos roles, ocultando datos sensibles. |
| **Procedimientos Almacenados** | Ofrecen una interfaz de acceso a datos segura, utilizando consultas parametrizadas para proteger contra ataques de **Inyección SQL**. |
| **Usuarios/Permisos** | Creación de usuarios de aplicación con privilegios mínimos (**Principio del Menor Privilegio**). |

## 🚀 Puesta en Marcha (Configuración de la BD)

Para levantar el esquema de la base de datos, sigue los siguientes pasos utilizando tu cliente SQL favorito (**DBeaver** o **MySQL Workbench**):

1.  **Requisitos:** Tener instalado un servidor **MySQL** o **MariaDB**. En mi caso personal funcionó con phpMyAdmin y workbench.
2.  **Crear Base de Datos:** Abre tu cliente SQL y ejecuta la siguiente instrucción para inicializar el esquema:
    ```sql
    CREATE DATABASE clinica53;
    USE clinica53;
    ```
3.  **Cargar Esquema:** Abre el archivo **`scripts para la base de datos clinica53.sql`**.
4.  **Ejecución:** Ejecuta el script completo. Este proceso:
    * Crea las tablas `Paciente` e `HistoriaClinica` con todas sus restricciones.
    * Define las claves foráneas, *checks* y *triggers*.
    * Crea las *vistas* y *procedimientos almacenados* definidos en el TFI.
    * Inserta datos de prueba si están incluidos en el script.

Tras ejecutar el script, la base de datos `clinica53` estará lista para ser utilizada por la aplicación Java/JDBC.
