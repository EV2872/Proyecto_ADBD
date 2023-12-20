/*
 * Autores: 
 *          Alejandro García Bautista 
 *          Evian Concepcion Peña 
 *          Edwin Plasencia Hernández
 * Asignatura: Administración y Diseño de Bases de Datos
 * Proyecto Final de la Asignatura
 * Resumen: Script general para montar la base de datos de saludtfe
 */

-- Creacion de la base de datos y todas sus tablas
DROP DATABASE IF EXISTS saludtfe;
CREATE DATABASE saludtfe;
-- Nos cambiamos de base de datos a la recien creada
\c saludtfe; 
\i tables.sql
\i triggers.sql
\i data.sql
\i views.sql