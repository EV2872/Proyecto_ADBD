-- Insertar datos para paciente_ss
INSERT INTO paciente_ss (nombre, dni, telefono, email, fecha_nacimiento, codigo_ss)
VALUES
  ('Ana García', '12345678A', '123456789', 'ana.garcia@email.com', '1990-05-15', 101),
  ('Carlos Martínez', '98765432B', '987654321', 'carlos.martinez@email.com', '1985-09-22', 102);

-- Insertar datos para paciente_sp
INSERT INTO paciente_sp (nombre, dni, telefono, email, fecha_nacimiento, codigo_sp, cobertura, aseguradora)
VALUES
  ('Luisa Pérez', '34567890C', '345678901', 'luisa.perez@email.com', '1982-12-08', 201, '1', 'Seguro A'),
  ('Javier Rodríguez', '56789012D', '567890123', 'javier.rodriguez@email.com', '1975-06-30', 202, '0.5', 'Seguro B'),
  ('Elena Fernández', '78901234E', '789012345', 'elena.fernandez@email.com', '1998-03-17', 203, '1', 'Seguro C');

-- Insertar datos para personal (médicos)
INSERT INTO personal (nombre, fecha_nacimiento, especialidad, tipo, m_cuota, m_descuento, e_consulta_propia)
VALUES
  ('Dr. Roberto Sánchez', '1978-04-25', 'Cardiologia', 'M', 80, 0.2, true),
  ('Dra. Laura González', '1985-09-15', 'Cabecera', 'M', 75, 0.1, true);

-- Insertar datos para personal (enfermeras)
INSERT INTO personal (nombre, fecha_nacimiento, especialidad, tipo, m_cuota, m_descuento, e_consulta_propia)
VALUES
  ('Enf. Marta Jiménez', '1990-11-12', 'Enfermeria', 'E', NULL, NULL, true),
  ('Enf. Pablo Gómez', '1982-07-08', 'Enfermeria', 'E', NULL, NULL, false);

-- Insertar datos para hospital
INSERT INTO hospital (nombre_hospital, telefono, ubicacion)
VALUES
  ('Hospital Central', '123456789', '(40.7128, -74.0060)'::POINT),
  ('Hospital del Norte', '987654321', '(41.8781, -87.6298)'::POINT),
  ('Hospital del Este', '555555555', '(34.0522, -118.2437)'::POINT);

-- Insertar plantas para Hospital Central
INSERT INTO planta (nombre_planta, piso, uso, id_hospital)
VALUES
  ('Urgencias', 1, 'Urgencias', 1),
  ('Consultas', 2, 'Consulta', 1),
  ('Almacen', 3, 'Almacen', 1),
  ('Diagnostico 1', 4, 'Diagnostico', 1),
  ('Diagnostico 2', 5, 'Diagnostico', 1),
  ('Hospitalizacion 1', 6, 'Hospitalizacion', 1),
  ('Hospitalizacion 2', 7, 'Hospitalizacion', 1),
  ('Hospitalizacion 3', 8, 'Hospitalizacion', 1),
  ('Hospitalizacion 4', 9, 'Hospitalizacion', 1),
  ('Diagnostico 3', 10, 'Diagnostico', 1);

-- Insertar plantas para Hospital del Norte
INSERT INTO planta (nombre_planta, piso, uso, id_hospital)
VALUES
  ('Urgencias', 1, 'Urgencias', 2),
  ('Consultas', 2, 'Consulta', 2),
  ('Almacen', 3, 'Almacen', 2),
  ('Diagnostico 1', 4, 'Diagnostico', 2),
  ('Hospitalizacion 1', 5, 'Hospitalizacion', 2),
  ('Diagnostico 2', 6, 'Diagnostico', 2);

-- Insertar plantas para Hospital del Este
INSERT INTO planta (nombre_planta, piso, uso, id_hospital)
VALUES
  ('Urgencias', 1, 'Urgencias', 3),
  ('Consultas', 2, 'Consulta', 3),
  ('Almacen', 3, 'Almacen', 3),
  ('Diagnostico 1', 4, 'Diagnostico', 3),
  ('Diagnostico 2', 5, 'Diagnostico', 3);

-- Insertar datos para material
INSERT INTO material (nombre)
VALUES
  ('Guantes estériles'),
  ('Paracetamol'),
  ('Vendas'),
  ('Analgésicos Generales'),
  ('Agujas'),
  ('Insulina');

-- Insertar datos para distribuidor
INSERT INTO distribuidor (nombre_distribuidor, telefono_emergencia, telefono_contacto, persona_contacto, id_material)
VALUES
  ('Distribuidor ABC', ARRAY['111', '222', '333'], '444555666', 'Juan Pérez', 1),
  ('Suministros XYZ', ARRAY['444', '555', '666'], '777888999', 'Ana Gómez', 3),
  ('Equipos Médicos S.A.', ARRAY['777', '888', '999'], '111222333', 'Carlos Rodríguez', 5);

-- Insertar datos para farmaceutica
INSERT INTO farmaceutica (nombre_farmaceutica, telefono_emergencia, telefono_contacto, persona_contacto, id_material)
VALUES
  ('Farmacia Rápida', ARRAY['222', '333', '444'], '555666777', 'Marta López', 2),
  ('MediHealth Solutions', ARRAY['555', '666', '777'], '888999000', 'Luis Torres', 4),
  ('PharmaCare', ARRAY['888', '999', '000'], '111222333', 'Elena Ramírez', 6);

-- Insertar datos para material_hospital
INSERT INTO material_hospital (id_hospital, id_material, cantidad)
VALUES
  (1, 1, 5),
  (1, 2, 10),
  (1, 3, 8),
  (2, 4, 15),
  (2, 5, 1), -- Usado para poder comprobar si funciona el trigger
  (2, 6, 20),
  (3, 2, 12),
  (3, 4, 25),
  (3, 1, 3),
  (3, 3, 30);

-- Contratos pasados
INSERT INTO contrato (colegiado, id_hospital, fecha_inicio, fecha_fin, horas_semanales, sueldo)
VALUES
  (1, 1, '2022-01-01', '2022-06-30', 20, 3000.00),
  (2, 2, '2021-09-01', '2022-03-31', 25, 3500.00),
  (3, 3, '2021-05-01', '2021-12-31', 30, 4000.00);

-- Nuevos contratos
INSERT INTO contrato (colegiado, id_hospital, fecha_inicio, horas_semanales, sueldo)
VALUES
  (1, 2, '2023-01-15', 15, 2000.00),
  (1, 3, '2023-04-01', 25, 3000.00),
  (2, 3, '2023-02-01', 20, 2500.00),
  (3, 1, '2023-03-01', 18, 2200.00),
  (4, 1, '2023-04-01', 40, 3000.00);
  
-- Insertar datos para uso_material_planta
INSERT INTO uso_material_planta (id_planta, id_material, cantidad_suministrada)
VALUES
  (1, 1, 3),
  (1, 2, 5),
  (11, 5, 1),
  (21, 3, 25);

-- Citas pasadas y futuras para paciente_ss
INSERT INTO cita_ss (historia_clinica, colegiado, id_hospital, fecha)
VALUES
  (1, 1, 1, '2022-05-15'), -- Pasada
  (1, 2, 1, '2023-01-10'), -- Futura
  (2, 3, 2, '2022-09-20'), -- Pasada
  (2, 4, 2, '2023-02-05'); -- Futura

-- Citas pasadas y futuras para paciente_sp
INSERT INTO cita_sp (historia_clinica, colegiado, id_hospital, fecha)
VALUES
  (3, 1, 2, '2022-07-10'), -- Pasada
  (3, 2, 2, '2023-03-15'), -- Futura
  (4, 3, 3, '2022-11-25'), -- Pasada
  (4, 4, 3, '2023-04-20'); -- Futura

-- Consultas pasadas para paciente_ss
INSERT INTO consultas_ss (historia_clinica, colegiado, fecha, diagnostico)
VALUES
  (1, 1,'2022-05-15', 'Consulta realizada por el Dr. Roberto Sánchez.'),
  (2, 2,'2022-05-15', 'Consulta realizada por la Dra. Laura González.'),
  (2, 3,'2022-09-20', 'Enfermera Marta Jiménez también evaluó al paciente y sugirió reposo.');

-- Consultas pasadas para paciente_sp
INSERT INTO consultas_sp (historia_clinica, colegiado, fecha, diagnostico)
VALUES
  (3, 1, '2022-07-10', 'Consulta realizada por el Dr. Roberto Sánchez.');
