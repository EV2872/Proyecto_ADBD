/*
 * Autores: 
 *          Alejandro García Bautista 
 *          Evian Concepcion Peña 
 *          Edwin Plasencia Hernández
 * Asignatura: Administración y Diseño de Bases de Datos
 * Proyecto Final de la Asignatura
 * Resumen: Script que hace uso de otros script para generar la base de datos de salud tinerfeña
 *          así como poblar sus tablas
 */

-- Creacion de la base de datos y todas sus tablas
DROP DATABASE IF EXISTS saludtfe;
CREATE DATABASE saludtfe;
-- Nos cambiamos de base de datos a la recien creada
\c saludtfe; 

\i creacion.sql
\i triggers.sql

\i insercion.sql
