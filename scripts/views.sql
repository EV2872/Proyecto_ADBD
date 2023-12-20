/*
 * Autores: 
 *          Alejandro García Bautista 
 *          Evian Concepcion Peña 
 *          Edwin Plasencia Hernández
 * Asignatura: Administración y Diseño de Bases de Datos
 * Proyecto Final de la Asignatura
 * Resumen: Script que crea vistas para simular los entornos de los
 *          usuarios
 */

CREATE VIEW vista_stock_hospital AS
SELECT
  h.id_hospital,
  h.nombre_hospital,
  m.nombre AS nombre_material,
  mh.cantidad AS cantidad_en_stock
FROM hospital h NATURAL JOIN material_hospital mh NATURAL JOIN material m;

CREATE VIEW vista_consultas AS
SELECT * FROM consultas_ss 
UNION 
SELECT * FROM consultas_sp;

CREATE VIEW vista_citas AS
SELECT
  pss.historia_clinica AS historia_clinica,
  pss.nombre AS nombre_paciente,
  c_ss.fecha AS fecha_cita,
  h.nombre_hospital,
  pe.nombre AS nombre_empleado
FROM
  cita_ss c_ss
JOIN
  paciente_ss pss ON c_ss.historia_clinica = pss.historia_clinica
JOIN
  personal pe ON c_ss.colegiado = pe.colegiado
JOIN
  hospital h ON c_ss.id_hospital = h.id_hospital
UNION ALL
SELECT
  psp.historia_clinica AS historia_clinica,
  psp.nombre AS nombre_paciente,
  c_sp.fecha AS fecha_cita,
  h.nombre_hospital,
  pe.nombre AS nombre_empleado
FROM
  cita_sp c_sp
JOIN
  paciente_sp psp ON c_sp.historia_clinica = psp.historia_clinica
JOIN
  personal pe ON c_sp.colegiado = pe.colegiado
JOIN
  hospital h ON c_sp.id_hospital = h.id_hospital;
  