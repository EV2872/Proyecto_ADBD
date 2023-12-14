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

CREATE TABLE paciente_sc (
  historia_clinica INTEGER PRIMARY KEY DEFAULT nextval('n_historia_clinica'),
  dni CHAR (9) NOT NULL UNIQUE CHECK (dni ~ '^[0-9]{8}[A-Za-z]$'),
  telefono CHAR (9) NOT NULL CHECK (telefono ~ '^[0-9]+$'),
  email VARCHAR (320),
  fecha_nacimiento DATE NOT NULL CHECK (fecha_nacimiento >= '1914-01-01' AND fecha_nacimiento <= CURRENT_DATE),
  codigo_sc INTEGER CHECK (codigo_sc > 0) UNIQUE
);

CREATE TABLE paciente_sp (
  historia_clinica INTEGER PRIMARY KEY DEFAULT nextval('n_historia_clinica'),
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
  nombre_hospital CHAR (9) NOT NULL,
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

CREATE TABLE consultas_sc (
  historia_clinica SERIAL REFERENCES paciente_sc(historia_clinica),
  total_pago FLOAT NOT NULL,
  fecha DATE NOT NULL,
  diagnostico TEXT NOT NULL
);

CREATE TABLE consultas_sp (
  historia_clinica SERIAL REFERENCES paciente_sp(historia_clinica),
  total_pago FLOAT NOT NULL,
  fecha DATE NOT NULL,
  diagnostico TEXT NOT NULL
);

CREATE TABLE material_hospital (
  lote SERIAL PRIMARY KEY,
  id_hospital SERIAL REFERENCES hospital(id_hospital) ON DELETE CASCADE NOT NULL,
  id_material SERIAL REFERENCES material(id_material) NOT NULL,
  cantidad INTEGER
);

CREATE TABLE contrato (
  colegiado SERIAL REFERENCES personal(colegiado) NOT NULL,
  id_hospital SERIAL REFERENCES hospital(id_hospital) ON DELETE CASCADE NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE,
  horas_semanales INTEGER CHECK (horas_semanales >= 5 AND horas_semanales <= 40) NOT NULL,
  sueldo FLOAT NOT NULL
);

CREATE TABLE cita_sc (
  historia_clinica SERIAL REFERENCES paciente_sc(historia_clinica) ON DELETE CASCADE NOT NULL,
  colegiado SERIAL REFERENCES personal(colegiado) ON DELETE CASCADE NOT NULL,
  id_hospital SERIAL REFERENCES hospital(id_hospital) ON DELETE CASCADE NOT NULL,
  fecha DATE
);

CREATE TABLE cita_sp (
  historia_clinica SERIAL REFERENCES paciente_sp(historia_clinica) ON DELETE CASCADE NOT NULL,
  colegiado SERIAL REFERENCES personal(colegiado) ON DELETE CASCADE NOT NULL,
  id_hospital SERIAL REFERENCES hospital(id_hospital) ON DELETE CASCADE NOT NULL,
  fecha DATE
);

CREATE TABLE uso_material_planta (
  id_planta SERIAL REFERENCES planta(id_planta) NOT NULL,
  id_material SERIAL REFERENCES material(id_material) NOT NULL,
  cantidad_suministrada INTEGER NOT NULL
);