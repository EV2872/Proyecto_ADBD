/*
 * Autores: Alejandro García Bautista, Evian Concepcion Peña, Edwin
 * Asignatura: Administración y Diseño de Bases de Datos
 * Resumen: Script que hace uso de otros script para generar la base de datos de viveros
 *          así como poblar sus tablas y hacer ciertas consultas
 */

-- Creacion de la base de datos y todas sus tablas
DROP DATABASE IF EXISTS saludtfe;
CREATE DATABASE saludtfe;
-- Nos cambiamos de base de datos a la recien creada
\c saludtfe; 

\i creacion.sql
\i triggers.sql

-- \i insercion.sql

-- \i operaciones.sql