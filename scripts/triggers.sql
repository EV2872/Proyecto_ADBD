-- Triggers
CREATE OR REPLACE FUNCTION check_contrato()
RETURNS TRIGGER AS $$
DECLARE
    total_horas_semanales INTEGER;
BEGIN
    -- Comprobar que el trabajador no trabaje en más de dos sitios a la vez
    SELECT COUNT(*)
    INTO total_horas_semanales
    FROM contrato
    WHERE NEW.colegiado = colegiado AND fecha_fin IS NULL;

    IF total_horas_semanales >= 2 THEN
        RAISE EXCEPTION 'El trabajador no puede trabajar en más de dos sitios a la vez.';
    END IF;

    -- Comprobar que el total de horas semanales no supere las 40
    SELECT COALESCE(SUM(horas_semanales), 0)
    INTO total_horas_semanales
    FROM contrato
    WHERE colegiado = NEW.colegiado AND fecha_fin IS NULL;

    IF total_horas_semanales + NEW.horas_semanales > 40 THEN
        RAISE EXCEPTION 'El total de horas semanales no puede superar las 40 horas.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_contratos
BEFORE INSERT ON contrato
FOR EACH ROW
EXECUTE FUNCTION check_contrato();

----------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION check_uso_material_planta()
RETURNS TRIGGER AS $$
DECLARE
    material_existente INTEGER;
    id_hospital_planta INTEGER;
    cantidad_disponible INTEGER;
BEGIN
    -- Obtener el id_hospital de la planta
    SELECT id_hospital
    INTO id_hospital_planta
    FROM planta
    WHERE id_planta = NEW.id_planta;

    -- Comprobar si el material existe en el hospital de la planta
    SELECT COUNT(*)
    INTO material_existente
    FROM material_hospital
    WHERE id_hospital = id_hospital_planta AND id_material = NEW.id_material;

    IF material_existente = 0 THEN
        RAISE EXCEPTION 'El material no está disponible en la planta.';
    END IF;

    -- Obtener la cantidad disponible del material en el hospital
    SELECT cantidad
    INTO cantidad_disponible
    FROM material_hospital
    WHERE id_hospital = id_hospital_planta AND id_material = NEW.id_material;

    -- Verificar si la cantidad_suministrada es mayor que la cantidad disponible
    IF NEW.cantidad_suministrada > cantidad_disponible THEN
        RAISE EXCEPTION 'La cantidad suministrada es mayor que la cantidad disponible del material en el hospital.';
    END IF;

    -- Restar la cantidad_suministrada a la cantidad en material_hospital
    UPDATE material_hospital
    SET cantidad = cantidad - NEW.cantidad_suministrada
    WHERE id_hospital = id_hospital_planta AND id_material = NEW.id_material;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se pudo restar la cantidad suministrada al material ya que no se ha encontrado.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- CREATE OR REPLACE FUNCTION check_uso_material_planta()
-- RETURNS TRIGGER AS $$
-- DECLARE
--     material_existente INTEGER;
--     id_hospital_planta INTEGER;
-- BEGIN
--     -- Obtener el id_hospital de la planta
--     SELECT id_hospital
--     INTO id_hospital_planta
--     FROM planta
--     WHERE id_planta = NEW.id_planta;

--     -- Comprobar si el material existe en el hospital de la planta
--     SELECT COUNT(*)
--     INTO material_existente
--     FROM material_hospital
--     WHERE id_hospital = id_hospital_planta AND id_material = NEW.id_material;

--     IF material_existente = 0 THEN
--         RAISE EXCEPTION 'El material no está disponible en la planta.';
--     END IF;

--     -- Restar la cantidad_suministrada a la cantidad en material_hospital
--     UPDATE material_hospital
--     SET cantidad = cantidad - NEW.cantidad_suministrada
--     WHERE id_hospital = id_hospital_planta AND id_material = NEW.id_material;

--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'No se pudo restar la cantidad suministrada al material ya que no se ha encontrado.';
--     END IF;

--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_stock
BEFORE INSERT ON uso_material_planta
FOR EACH ROW
EXECUTE FUNCTION check_uso_material_planta();

----------------------------------------------------------------------------------------------

-- Trigger para consulta_ss
CREATE OR REPLACE FUNCTION calcular_total_pago_ss()
RETURNS TRIGGER AS $$
DECLARE
    n_medico_colegiado INTEGER;
    descuento FLOAT; 
    fecha_ultima_cita DATE;
BEGIN
    -- Obtener el colegiado del médico para la consulta_ss
    SELECT colegiado, fecha
    INTO n_medico_colegiado, fecha_ultima_cita
    FROM cita_ss
    WHERE historia_clinica = NEW.historia_clinica AND colegiado = NEW.colegiado
    ORDER BY fecha DESC
    LIMIT 1;

    SELECT m_cuota
    INTO NEW.total_pago
    FROM personal
    WHERE colegiado = NEW.colegiado;

    -- Verificar si el médico tiene al menos una consulta anterior con el paciente_ss
    IF n_medico_colegiado IS NOT NULL AND fecha_ultima_cita IS NOT NULL AND fecha_ultima_cita < NEW.fecha THEN
        -- Obtener la cuota del médico
        SELECT m_descuento
        INTO descuento
        FROM personal
        WHERE colegiado = n_medico_colegiado;

        -- Aplicar descuento si el médico tiene cuota
        IF NEW.total_pago IS NOT NULL THEN
            NEW.total_pago := NEW.total_pago - (NEW.total_pago * descuento);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER a_pagar_consulta_ss
BEFORE INSERT ON consultas_ss
FOR EACH ROW
EXECUTE FUNCTION calcular_total_pago_ss();

-- Trigger para consulta_sp
CREATE OR REPLACE FUNCTION calcular_total_pago_sp()
RETURNS TRIGGER AS $$
DECLARE
    cobertura_paciente COBERTURA;
BEGIN
    -- Obtener la cobertura del paciente_sp
    SELECT cobertura
    INTO cobertura_paciente
    FROM paciente_sp
    WHERE historia_clinica = NEW.historia_clinica;

    -- Verificar si la cobertura es válida y aplicar descuento
    IF cobertura_paciente IS NOT NULL THEN
        -- Obtener la cuota del médico
        SELECT m_cuota
        INTO NEW.total_pago
        FROM personal
        WHERE colegiado = NEW.colegiado;

        -- Aplicar descuento según la cobertura
        IF cobertura_paciente = '1' THEN
            -- Aplicar descuento del 100%
            NEW.total_pago := 0; -- Descuento del 100%
        ELSIF cobertura_paciente = '0.5' THEN
            -- Aplicar descuento del 50%
            NEW.total_pago := NEW.total_pago * 0.5;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER a_pagar_consulta_sp
BEFORE INSERT ON consultas_sp
FOR EACH ROW
EXECUTE FUNCTION calcular_total_pago_sp();
