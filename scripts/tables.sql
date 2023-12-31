/*
 * Autores: 
 *          Alejandro García Bautista 
 *          Evian Concepcion Peña 
 *          Edwin Plasencia Hernández
 * Asignatura: Administración y Diseño de Bases de Datos
 * Proyecto Final de la Asignatura
 * Resumen: Script que crea las diferentes tablas de la base de datos
 */

-- SECUENCIAS
CREATE SEQUENCE n_historia_clinica;

-- ENUMS
CREATE TYPE COBERTURA AS ENUM ('0.5', '1');
CREATE TYPE TIPO AS ENUM ('M', 'E');
CREATE TYPE USO AS ENUM (
  'Especializacion', 
  'Urgencias', 
  'Almacen', 
  'Consulta', 
  'Recepcion', 
  'Diagnostico',
  'Hospitalizacion',
  'Garaje');
CREATE TYPE ESPECIALIDAD AS ENUM(
  'Traumatologia',
  'Ginecologia',
  'Cabecera',
  'Rehabilitacion',
  'Enfermeria',
  'Cardiologia',
  'Dermatologia',
  'Oftalmologia',
  'Otorrinolaringologia',
  'Neurologia',
  'Pediatria',
  'Urologia',
  'Psiquiatria',
  'Oncologia',
  'Endocrinologia',
  'Nefrologia'
);

-- TABLAS
CREATE TABLE paciente_ss (
  historia_clinica INTEGER PRIMARY KEY DEFAULT nextval('n_historia_clinica'),
  nombre VARCHAR(250) NOT NULL,
  dni CHAR (9) NOT NULL UNIQUE CHECK (dni ~ '^[0-9]{8}[A-Za-z]$'),
  telefono CHAR (9) NOT NULL CHECK (telefono ~ '^[0-9]+$'),
  email VARCHAR (320),
  fecha_nacimiento DATE NOT NULL CHECK (fecha_nacimiento >= '1914-01-01' AND fecha_nacimiento <= CURRENT_DATE),
  codigo_ss INTEGER CHECK (codigo_ss > 0) UNIQUE
);

CREATE TABLE paciente_sp (
  historia_clinica INTEGER PRIMARY KEY DEFAULT nextval('n_historia_clinica'),
  nombre VARCHAR(250) NOT NULL,
  dni CHAR (9) NOT NULL UNIQUE CHECK (dni ~ '^[0-9]{8}[A-Za-z]$'),
  telefono CHAR (9) NOT NULL CHECK (telefono ~ '^[0-9]+$'),
  email VARCHAR (320),
  fecha_nacimiento DATE NOT NULL CHECK (fecha_nacimiento >= '1914-01-01' AND fecha_nacimiento <= CURRENT_DATE),
  codigo_sp INTEGER NOT NULL CHECK (codigo_sp > 0) UNIQUE,
  cobertura COBERTURA NOT NULL,
  aseguradora VARCHAR(50) NOT NULL
);

CREATE TABLE personal (
  colegiado SERIAL PRIMARY KEY,
  nombre VARCHAR(20) NOT NULL,
  fecha_nacimiento DATE NOT NULL CHECK (fecha_nacimiento >= '1914-01-01' AND fecha_nacimiento <= CURRENT_DATE),
  especialidad ESPECIALIDAD NOT NULL,
  tipo TIPO NOT NULL,
  m_cuota FLOAT CHECK (m_cuota >= 50),
  m_descuento FLOAT CHECK (m_descuento >= 0 AND m_descuento <= 1),
  e_consulta_propia BOOLEAN
);

CREATE TABLE hospital (
  id_hospital SERIAL PRIMARY KEY,
  nombre_hospital VARCHAR (100) NOT NULL,
  telefono CHAR (9) NOT NULL CHECK (telefono ~ '^[0-9]+$'),
  ubicacion POINT NOT NULL
);

CREATE TABLE planta (
  id_planta SERIAL PRIMARY KEY,
  nombre_planta VARCHAR (50) NOT NULL,
  piso INTEGER NOT NULL,
  uso USO NOT NULL,
  id_hospital SERIAL REFERENCES hospital(id_hospital) ON DELETE CASCADE NOT NULL
);

CREATE TABLE material (
  id_material SERIAL PRIMARY KEY,
  nombre VARCHAR(250) NOT NULL
);

CREATE TABLE distribuidor (
  id_distribuidor SERIAL PRIMARY KEY,
  nombre_distribuidor VARCHAR(50) NOT NULL,
  telefono_emergencia CHAR(9)[3] NOT NULL,
  telefono_contacto CHAR(9) NOT NULL CHECK (telefono_contacto ~ '^[0-9]+$'),
  persona_contacto VARCHAR (50) NOT NULL,
  id_material SERIAL REFERENCES material(id_material)
);

CREATE TABLE farmaceutica (
  id_farmaceutica SERIAL PRIMARY KEY,
  nombre_farmaceutica VARCHAR (50) NOT NULL,
  telefono_emergencia CHAR(9)[3] NOT NULL,
  telefono_contacto CHAR (9) NOT NULL CHECK (telefono_contacto ~ '^[0-9]+$'),
  persona_contacto VARCHAR (50),
  id_material SERIAL REFERENCES material(id_material)
);

-- Relaciones

CREATE TABLE consultas_ss (
  historia_clinica SERIAL REFERENCES paciente_ss(historia_clinica) ON DELETE CASCADE,
  colegiado SERIAL REFERENCES personal(colegiado) ON DELETE CASCADE,
  total_pago FLOAT,
  fecha DATE NOT NULL CHECK (fecha >= '1914-01-01' AND fecha <= CURRENT_DATE),
  diagnostico TEXT NOT NULL
);

CREATE TABLE consultas_sp (
  historia_clinica SERIAL REFERENCES paciente_sp(historia_clinica) ON DELETE CASCADE,
  colegiado SERIAL REFERENCES personal(colegiado) ON DELETE CASCADE,
  total_pago FLOAT,
  fecha DATE NOT NULL CHECK (fecha >= '1914-01-01' AND fecha <= CURRENT_DATE),
  diagnostico TEXT NOT NULL
);

CREATE TABLE material_hospital (
  id_hospital SERIAL REFERENCES hospital(id_hospital) ON DELETE CASCADE NOT NULL,
  id_material SERIAL REFERENCES material(id_material) ON DELETE CASCADE NOT NULL,
  cantidad INTEGER
);

CREATE TABLE contrato (
  colegiado SERIAL REFERENCES personal(colegiado) ON DELETE CASCADE NOT NULL,
  id_hospital SERIAL REFERENCES hospital(id_hospital) ON DELETE CASCADE NOT NULL,
  fecha_inicio DATE NOT NULL CHECK (fecha_inicio >= '1914-01-01' AND fecha_inicio <= CURRENT_DATE),
  fecha_fin DATE CHECK (fecha_fin >= '1914-01-01' AND fecha_fin <= CURRENT_DATE),
  horas_semanales INTEGER CHECK (horas_semanales >= 5 AND horas_semanales <= 40) NOT NULL,
  sueldo FLOAT NOT NULL
);

CREATE TABLE cita_ss (
  historia_clinica SERIAL REFERENCES paciente_ss(historia_clinica) ON DELETE CASCADE NOT NULL,
  colegiado SERIAL REFERENCES personal(colegiado) ON DELETE CASCADE NOT NULL,
  id_hospital SERIAL REFERENCES hospital(id_hospital) ON DELETE CASCADE NOT NULL,
  fecha DATE CHECK (fecha >= '1914-01-01')
);

CREATE TABLE cita_sp (
  historia_clinica SERIAL REFERENCES paciente_sp(historia_clinica) ON DELETE CASCADE NOT NULL,
  colegiado SERIAL REFERENCES personal(colegiado) ON DELETE CASCADE NOT NULL,
  id_hospital SERIAL REFERENCES hospital(id_hospital) ON DELETE CASCADE NOT NULL,
  fecha DATE CHECK (fecha >= '1914-01-01')
);

CREATE TABLE uso_material_planta (
  id_planta SERIAL REFERENCES planta(id_planta) ON DELETE CASCADE NOT NULL,
  id_material SERIAL REFERENCES material(id_material) ON DELETE CASCADE NOT NULL,
  cantidad_suministrada INTEGER NOT NULL
);