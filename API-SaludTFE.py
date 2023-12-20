import os
import psycopg2
from flask import Flask, request, url_for, jsonify, Response
from psycopg2 import OperationalError
import sys

app = Flask(__name__)

def get_db_connection():
  try:
    conn = psycopg2.connect(
      host='localhost',
      port=5432,
      database="saludtfe",
      user="postgres",
      password="password")
    return conn
  except OperationalError as err:
    print(f"Error connecting to database: {err}")
    sys.exit("Flask App closed due to database connection error")

@app.route('/administra/hospital')
def get_hospitales():
  conn = get_db_connection()
  cur = conn.cursor()
  cur.execute('SELECT * FROM hospital')
  hospitales = cur.fetchall()
  if hospitales:
    resultado = {
      "hospitales": []
    }
    for hospital in hospitales:
      resultado["hospitales"].append({
        "id_hospital": hospital[0],
        "nombre": hospital[1]
      })
    return jsonify(resultado), 200
  else:
    return Response("{'msg': 'No hay hospitales registrados'}", status=404, mimetype='application/json')

@app.route('/administra/hospital/<int:id_hospital>')
def get_hospital(id_hospital):
  conn = get_db_connection()
  cur = conn.cursor()

  cur.execute("SELECT * FROM hospital WHERE id_hospital = %s", (id_hospital, ))
  hospital = cur.fetchone()

  if hospital:
    resultado = {
      "id_hospital": hospital[0],
      "nombre": hospital[1],
      "telefono": hospital[2],
      "ubicacion": hospital[3]
    }
    return jsonify(resultado), 200
  else:
    return Response("{'msg': 'No se encuentra el hospital especificado'}", status=404, mimetype='application/json')

@app.route('/administra/stock_hospital/<int:id_hospital>')
def get_stock_hospital(id_hospital):
  conn = get_db_connection()
  cur = conn.cursor()

  cur.execute("SELECT * FROM vista_stock_hospital WHERE id_hospital = %s", (id_hospital, ))
  stock = cur.fetchall()

  if stock:
    resultado = {
      "almacen_hospital": {
        "id_hospital": stock[0][0],
        "nombre_hospital": stock[0][1],
        "stock": []
      }
    }

    for element in stock:
      resultado["hospital"]["stock"].append({
        "nombre_material": element[2],
        "cantidad_stock": element[3]
      })
    return jsonify(resultado), 200
  else:
    return Response("{'msg': 'No se encuentra el hospital especificado'}", status=404, mimetype='application/json')

@app.route('/administra/material')
def get_materiales():
  conn = get_db_connection()
  cur = conn.cursor()
  cur.execute('SELECT * FROM material')
  materiales = cur.fetchall()

  if materiales:
    resultado = {
      "materiales": []
    }
    for material in materiales:
      resultado["materiales"].append({
        "id_material": material[0],
        "nombre": material[1]
      })
    return jsonify(resultado), 200
  else:
    return Response("{'msg': 'No hay materiales registrados'}", status=404, mimetype='application/json')

@app.route('/administra/material/<int:id_material>/hospital/<int:id_hospital>/cantidad/<int:cantidad>', methods=['POST'])
def add_material(id_material, id_hospital, cantidad):
  if request.method == 'POST':
    try:
      conn = get_db_connection()
      cur = conn.cursor()
      log = cur.execute('INSERT INTO material_hospital (id_hospital, id_material, cantidad) VALUES (%s, %s, %s)', (id_hospital, id_material, cantidad))
      conn.commit()

      return Response("{'msg': 'Registro añadido correctamente'}", status=200, mimetype='application/json')
    except:
      return Response("{'msg': 'Error al insertar datos en la base de datos'}", status=404, mimetype='application/json')
  else:
    return Response("{'msg': 'Verbo no valido'}", status=404, mimetype='application/json')

@app.route('/administra/uso', methods=['POST'])
def usar_material():
  if request.method == 'POST':
    try:
      conn = get_db_connection()
      cur = conn.cursor()

      datos = request.json

      cur.execute('INSERT INTO uso_material_planta (id_planta, id_material, cantidad_suministrada) VALUES (%s, %s, %s)', (datos["id_planta"], datos["id_material"], datos["cantidad_suministrada"], ))
      log = conn.commit()

      return Response("{'msg': 'Registro añadido correctamente'}", status=200, mimetype='application/json')
    except:
      return Response("{'msg': 'Error al insertar datos en la base de datos'}", status=404, mimetype='application/json')
  else:
    return Response("{'msg': 'Verbo no valido'}", status=404, mimetype='application/json')

@app.route('/administra/actualizar', methods=['PATCH'])
def actualizar_material():
  if request.method == 'PATCH':
    try:
      conn = get_db_connection()
      cur = conn.cursor()
      datos = request.json
      cur.execute('UPDATE material_hospital SET cantidad = %s WHERE id_hospital = %s AND id_material = %s ', (datos["cantidad"], datos["id_hospital"], datos["id_material"], ))
      log = conn.commit()

      return Response("{'msg': 'Registro actualizado correctamente'}", status=200, mimetype='application/json')
    except:
      return Response("{'msg': 'Error al actualizar los datos'}", status=404, mimetype='application/json')
  else:
    return Response("{'msg': 'Verbo no valido'}", status=404, mimetype='application/json')

@app.route('/trabajadores')
def get_trabajadores():
  conn = get_db_connection()
  cur = conn.cursor()
  cur.execute('SELECT * FROM personal')
  trabajadores = cur.fetchall()
  if trabajadores:
    resultado = {
      "trabajadores": []
    }
    for trabajador in trabajadores:
      resultado["trabajadores"].append({
        "colegiado": trabajador[0],
        "nombre": trabajador[1],
        "fecha_nacimiento": trabajador[2],
        "especialidad": trabajador[3],
        "tipo": trabajador[3],
        "m_cuota": trabajador[3],
        "m_descuento": trabajador[3],
        "e_consulta_propia": trabajador[3]
      })
    return jsonify(resultado), 200
  else:
    return Response("{'msg': 'No hay trabajadores registrados'}", status=404, mimetype='application/json')

@app.route('/trabajadores/<int:colegiado>', methods=['GET', 'DELETE', 'PATCH'])
def get_delete_trabajador(colegiado):
  if request.method == 'GET':
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT * FROM personal WHERE colegiado = %s", (colegiado, ))
    personal = cur.fetchone()

    if personal:
      resultado = {
        "colegiado": personal[0],
        "nombre": personal[1],
        "fecha_nacimiento": personal[2],
        "especialidad": personal[3],
        "tipo": personal[4],
        "m_cuota": personal[5],
        "m_descuento": personal[6],
        "e_consulta_propia": personal[7]
      }
      return jsonify(resultado), 200
    else:
      return Response("{'msg': 'No se encuentra el trabajador especificado'}", status=404, mimetype='application/json')
  elif request.method == 'DELETE':
    try:
      conn = get_db_connection()
      cur = conn.cursor()
      cur.execute('DELETE FROM personal WHERE colegiado = %s', (colegiado, ))
      conn.commit()
      return Response("{'msg': 'Trabajador borrado'}", status=200, mimetype='application/json')
    except:
      return Response("{'msg': 'Trabajador no encontrado'}", status=404, mimetype='application/json')
  elif request.method == 'PATCH':
    try:
      conn = get_db_connection()
      cur = conn.cursor()
      
      datos = request.json
      campo_a_actualizar = datos["campo_a_actualizar"]
      nuevo_valor = datos["nuevo_valor"]
      columnas_validas = ["especialidad", "m_cuota", "m_descuento", "e_consulta_propia"]
      if campo_a_actualizar not in columnas_validas:
        return Response("{'msg': 'Columna no válida para actualizar'}", status=400, mimetype='application/json')

      cur.execute(f"UPDATE personal SET {campo_a_actualizar} = %s WHERE colegiado = %s", (nuevo_valor, colegiado, ))
      filas_afectadas = cur.rowcount
      conn.commit()

      if filas_afectadas != 0:
        return Response("{'msg': 'Registro actualizado correctamente'}", status=200, mimetype='application/json')
      
      return Response("{'msg': 'Algo a ido mal en la actualización, el colegiado no se a encontrado'}", status=404, mimetype='application/json')      
    except:
      return Response("{'msg': 'Error al actualizar el registro'}", status=404, mimetype='application/json')
  else:
    return Response("{'msg': 'Verbo no valido'}", status=404, mimetype='application/json')


@app.route('/trabajadores/hospital/<int:id_hospital>')
def get_trabajador_hospital(id_hospital):
  conn = get_db_connection()
  cur = conn.cursor()
  cur.execute("SELECT colegiado, nombre, fecha_nacimiento, especialidad, tipo, m_cuota, m_descuento, e_consulta_propia FROM contrato NATURAL JOIN personal WHERE id_hospital = %s", (id_hospital, ))
  personal = cur.fetchall()

  if personal:
    resultado = {
      "personal": []
    }
    for persona in personal:
      resultado["personal"].append({
        "colegiado": persona[0],
        "nombre": persona[1],
        "fecha_nacimiento": persona[2],
        "especialidad": persona[3],
        "tipo": persona[4],
        "m_cuota": persona[5],
        "m_descuento": persona[6],
        "e_consulta_propia": persona[7]
      })
    return jsonify(resultado), 200
  else:
    return Response("{'msg': 'No se encuentra el trabajador especificado'}", status=404, mimetype='application/json')

@app.route('/trabajadores/<int:colegiado>/contratos')
def get_contratos(colegiado):
  conn = get_db_connection()
  cur = conn.cursor()
  cur.execute("SELECT * FROM contrato WHERE colegiado = %s", (colegiado, ))
  contratos = cur.fetchall()

  if contratos:
    resultado = {
      "contratos": []
    }
    for persona in contratos:
      resultado["contratos"].append({
        "colegiado": persona[0],
        "id_hospital": persona[1],
        "fecha_inicio": persona[2],
        "fecha_fin": persona[3],
        "horas_semanales": persona[4],
        "sueldo": persona[5]
      })
    return jsonify(resultado), 200
  else:
    return Response("{'msg': 'No se encuentran contratos del trabajador especificado'}", status=404, mimetype='application/json')

@app.route('/trabajadores/nuevo', methods=['POST'])
def actualizar_trabajador():
  if request.method == 'POST':
    try:
      conn = get_db_connection()
      cur = conn.cursor()
      datos = request.json
      cur.execute('INSERT INTO personal (nombre, fecha_nacimiento, especialidad, tipo, m_cuota, m_descuento, e_consulta_propia) VALUES (%s, %s, %s, %s, %s, %s, %s)', (datos["nombre"], datos["fecha_nacimiento"], datos["especialidad"], datos["tipo"], datos["m_cuota"], datos["m_descuento"], datos["e_consulta_propia"]))
      conn.commit()
      
      return Response("{'msg': 'Registro añadido correctamente'}", status=200, mimetype='application/json')
    except:
      return Response("{'msg': 'Error al insertar datos en la base de datos'}", status=404, mimetype='application/json')
  else:
    return Response("{'msg': 'Verbo no valido'}", status=404, mimetype='application/json')

@app.route('/consulta/<int:colegiado>/paciente/<int:historia_clinica>')
def get_info_consultas(colegiado, historia_clinica):
  conn = get_db_connection()
  cur = conn.cursor()
  cur.execute('SELECT fecha, diagnostico FROM vista_consultas WHERE colegiado = %s AND historia_clinica = %s', (colegiado, historia_clinica, ))
  consultas = cur.fetchall()
  if consultas:
    resultado = {
      "consultas": []
    }
    for consulta in consultas:
      resultado["consultas"].append({
        "fecha": consulta[0],
        "diagnostico": consulta[1]
      })
    return jsonify(resultado), 200
  else:
    return Response("{'msg': 'No hay registros con ese colegiado e historia clinica'}", status=404, mimetype='application/json')

@app.route('/consulta/paciente/<int:historia_clinica>')
def get_todas_consultas(historia_clinica):
  conn = get_db_connection()
  cur = conn.cursor()
  cur.execute('SELECT fecha, diagnostico FROM vista_consultas WHERE historia_clinica = %s', (historia_clinica, ))
  consultas = cur.fetchall()
  if consultas:
    resultado = {
      "consultas": []
    }
    for consulta in consultas:
      resultado["consultas"].append({
        "fecha": consulta[0],
        "diagnostico": consulta[1]
      })
    return jsonify(resultado), 200
  else:
    return Response("{'msg': 'No hay registros de ese paciente'}", status=404, mimetype='application/json')

@app.route('/consulta/nueva', methods=['POST'])
def add_consultas():
  if request.method == 'POST':
    try:
      conn = get_db_connection()
      cur = conn.cursor()

      datos = request.json

      if datos["tipo_paciente"] == "ss":
        cur.execute('INSERT INTO consultas_ss (historia_clinica, colegiado, fecha, diagnostico) VALUES (%s, %s, %s, %s)', (datos["historia_clinica"], datos["colegiado"], datos["fecha"], datos["diagnostico"], ))    
      elif datos["tipo_paciente"] == "sp":
        cur.execute('INSERT INTO consultas_sp (historia_clinica, colegiado, fecha, diagnostico) VALUES (%s, %s, %s, %s)', (datos["historia_clinica"], datos["colegiado"], datos["fecha"], datos["diagnostico"], ))
      else:
        return Response("{'msg': 'Error, debes indicar si es un paciente de la seguridad social (ss) o de seguro privado (sp)'}", status=200, mimetype='application/json')

      conn.commit()
      return Response("{'msg': 'Consulta añadida'}", status=200, mimetype='application/json')
    except:
      return Response("{'msg': 'Error al insertar la consulta'}", status=404, mimetype='application/json')
  else:
    return Response("{'msg': 'Verbo no valido'}", status=404, mimetype='application/json')

@app.route('/consulta/<int:colegiado>/paciente/<int:historia_clinica>/fecha/<string:fecha>', methods=['PATCH'])
def update_consultas(colegiado, historia_clinica, fecha):
  if request.method == 'PATCH':
    try:
      conn = get_db_connection()
      cur = conn.cursor()

      datos = request.json

      campo_a_actualizar = datos["campo_a_actualizar"]
      nuevo_valor = datos["nuevo_valor"]
      columnas_validas = ["fecha", "diagnostico"]
      if campo_a_actualizar not in columnas_validas:
        return Response("{'msg': 'Columna no válida para actualizar'}", status=400, mimetype='application/json')

      if datos["tipo_paciente"] == "ss":
        cur.execute(f"UPDATE consultas_ss SET {campo_a_actualizar} = %s WHERE colegiado = %s AND historia_clinica = %s AND fecha = %s", (nuevo_valor, colegiado, historia_clinica, fecha, ))  
      elif datos["tipo_paciente"] == "sp":
        cur.execute(f"UPDATE consultas_sp SET {campo_a_actualizar} = %s WHERE colegiado = %s AND historia_clinica = %s AND fecha = %s", (nuevo_valor, colegiado, historia_clinica, fecha, ))
      else:
        return Response("{'msg': 'Error, debes indicar si es un paciente de la seguridad social (ss) o de seguro privado (sp)'}", status=200, mimetype='application/json')
        
      filas_afectadas = cur.rowcount
      conn.commit()

      if filas_afectadas != 0:
        return Response("{'msg': 'Registro actualizado correctamente'}", status=200, mimetype='application/json')
      
      return Response("{'msg': 'Algo a ido mal en la actualización, revisa los parametros de la consulta'}", status=404, mimetype='application/json')      
    except:
      return Response("{'msg': 'Error al actualizar el registro'}", status=404, mimetype='application/json')
  else:
    return Response("{'msg': 'Verbo no valido'}", status=404, mimetype='application/json')

@app.route('/paciente')
def citas_pacientes():
  conn = get_db_connection()
  cur = conn.cursor()
  cur.execute('SELECT * FROM vista_citas WHERE fecha_cita >= CURRENT_DATE')
  citas = cur.fetchall()
  if citas:
    resultado = {
      "citas": []
    }
    for cita in citas:
      resultado["citas"].append({
        "paciente": cita[1],
        "fecha": cita[2],
        "hospital": cita[3],
        "profesional": cita[4],
      })
    return jsonify(resultado), 200
  else:
    return Response("{'msg': 'No hay citas pendientes'}", status=404, mimetype='application/json')

@app.route('/paciente/<int:historia_clinica>')
def citas_paciente(historia_clinica):
  conn = get_db_connection()
  cur = conn.cursor()
  cur.execute('SELECT * FROM vista_citas WHERE fecha_cita >= CURRENT_DATE AND historia_clinica = %s', (historia_clinica, ))
  citas = cur.fetchall()
  if citas:
    resultado = {
      "citas": []
    }
    for cita in citas:
      resultado["citas"].append({
        "paciente": cita[1],
        "fecha": cita[2],
        "hospital": cita[3],
        "profesional": cita[4],
      })
    return jsonify(resultado), 200
  else:
    return Response("{'msg': 'No hay citas pendientes para este paciente'}", status=404, mimetype='application/json')

@app.route('/paciente/pasadas/<int:historia_clinica>')
def citas_anteriores_paciente(historia_clinica):
  conn = get_db_connection()
  cur = conn.cursor()
  cur.execute('SELECT * FROM vista_citas WHERE fecha_cita <= CURRENT_DATE AND historia_clinica = %s', (historia_clinica, ))
  citas = cur.fetchall()
  if citas:
    resultado = {
      "citas": []
    }
    for cita in citas:
      resultado["citas"].append({
        "paciente": cita[1],
        "fecha": cita[2],
        "hospital": cita[3],
        "profesional": cita[4],
      })
    return jsonify(resultado), 200
  else:
    return Response("{'msg': 'No hay citas pendientes para este paciente'}", status=404, mimetype='application/json')

@app.route('/paciente/alta', methods=['POST'])
def alta_paciente():
  if request.method == 'POST':
    try:
      conn = get_db_connection()
      cur = conn.cursor()

      datos = request.json

      if datos["tipo_paciente"] == "ss":
        print("AQUI")
        cur.execute('INSERT INTO paciente_ss(nombre, dni, telefono, email, fecha_nacimiento, codigo_ss) VALUES (%s, %s, %s, %s, %s, %s)', (datos["nombre"], datos["dni"], datos["telefono"], datos["email"], datos["fecha_nacimiento"], datos["codigo_ss"], ))    
      elif datos["tipo_paciente"] == "sp":
        cur.execute('INSERT INTO paciente_sp(nombre, dni, telefono, email, fecha_nacimiento, codigo_sp, cobertura, aseguradora) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)', (datos["nombre"], datos["dni"], datos["telefono"], datos["email"], datos["fecha_nacimiento"], datos["codigo_sp"], datos["cobertura"], datos["aseguradora"], ))
      else:
        return Response("{'msg': 'Error, debes indicar si es un paciente de la seguridad social (ss) o de seguro privado (sp)'}", status=200, mimetype='application/json')

      conn.commit()
      return Response("{'msg': 'Paciente añadido'}", status=200, mimetype='application/json')
    except:
      return Response("{'msg': 'Error al insertar el paciente'}", status=404, mimetype='application/json')
  else:
    return Response("{'msg': 'Verbo no valido'}", status=404, mimetype='application/json')

@app.route('/paciente/baja/<int:historia_clinica>', methods=['DELETE'])
def baja_paciente(historia_clinica):
  if request.method == 'DELETE':
    try:
      conn = get_db_connection()
      cur = conn.cursor()

      datos = request.json

      if datos["tipo_paciente"] == "ss":
        cur.execute('DELETE FROM paciente_ss WHERE historia_clinica = %s', (historia_clinica, ))
      elif datos["tipo_paciente"] == "sp":
        cur.execute('DELETE FROM paciente_sp WHERE historia_clinica = %s', (historia_clinica, ))
      else:
        return Response("{'msg': 'Error, debes indicar si es un paciente de la seguridad social (ss) o de seguro privado (sp)'}", status=200, mimetype='application/json')

      conn.commit()
      return Response("{'msg': 'Paciente dado de baja del sistema'}", status=200, mimetype='application/json')
    except:
      return Response("{'msg': 'Error al eliminar el paciente del sistema'}", status=404, mimetype='application/json')
  else:
    return Response("{'msg': 'Verbo no valido'}", status=404, mimetype='application/json')

@app.route('/paciente/nueva_cita', methods=['POST', 'DELETE', 'PATCH'])
def gestion_citas():
  if request.method == 'POST':
    try:
      conn = get_db_connection()
      cur = conn.cursor()

      datos = request.json

      if datos["tipo_paciente"] == "ss":
        print("AQUI 1")
        cur.execute('INSERT INTO cita_ss (historia_clinica, colegiado, id_hospital, fecha) VALUES(%s, %s, %s, %s)', (datos["historia_clinica"], datos["colegiado"], datos["id_hospital"], datos["fecha"], ))
      elif datos["tipo_paciente"] == "sp":
        print("AQUI 2")
        cur.execute('INSERT INTO cita_sp (historia_clinica, colegiado, id_hospital, fecha) VALUES(%s, %s, %s, %s)', (datos["historia_clinica"], datos["colegiado"], datos["id_hospital"], datos["fecha"], ))
      else:
        return Response("{'msg': 'Error, debes indicar si es un paciente de la seguridad social (ss) o de seguro privado (sp)'}", status=200, mimetype='application/json')

      conn.commit()
      return Response("{'msg': 'Nueva cita añadida para el paciente indicado'}", status=200, mimetype='application/json')
    except:
      return Response("{'msg': 'Error al añadir la cita, revisa el body de tu petición'}", status=404, mimetype='application/json')
  elif request.method == 'DELETE':
    try:
      conn = get_db_connection()
      cur = conn.cursor()

      datos = request.json

      if datos["tipo_paciente"] == "ss":
        cur.execute('DELETE FROM cita_ss WHERE historia_clinica = %s AND colegiado = %s AND fecha = %s', (datos["historia_clinica"], datos["colegiado"], datos["fecha"], ))
      elif datos["tipo_paciente"] == "sp":
        cur.execute('DELETE FROM cita_sp WHERE historia_clinica = %s AND colegiado = %s AND fecha = %s', (datos["historia_clinica"], datos["colegiado"], datos["fecha"], ))
      else:
        return Response("{'msg': 'Error, debes indicar si es un paciente de la seguridad social (ss) o de seguro privado (sp)'}", status=200, mimetype='application/json')

      conn.commit()
      return Response("{'msg': 'Cita eliminada'}", status=200, mimetype='application/json')
    except:
      return Response("{'msg': 'Error al eliminar la cita del paciente, revisa el body de tu petición'}", status=404, mimetype='application/json')
  elif request.method == 'PATCH':
    try:
      conn = get_db_connection()
      cur = conn.cursor()

      datos = request.json

      campo_a_actualizar = datos["campo_a_actualizar"]
      nuevo_valor = datos["nuevo_valor"]
      colegiado = datos["colegiado"]
      historia_clinica = datos["historia_clinica"]
      fecha = datos["fecha"]

      columnas_validas = ["fecha", "id_hospital"]
      if campo_a_actualizar not in columnas_validas:
        return Response("{'msg': 'Columna no válida para actualizar'}", status=400, mimetype='application/json')

      if datos["tipo_paciente"] == "ss":
        cur.execute(f"UPDATE cita_ss SET {campo_a_actualizar} = %s WHERE colegiado = %s AND historia_clinica = %s AND fecha = %s", (nuevo_valor, colegiado, historia_clinica, fecha, ))  
      elif datos["tipo_paciente"] == "sp":
        cur.execute(f"UPDATE cita_sp SET {campo_a_actualizar} = %s WHERE colegiado = %s AND historia_clinica = %s AND fecha = %s", (nuevo_valor, colegiado, historia_clinica, fecha, ))
      else:
        return Response("{'msg': 'Error, debes indicar si es un paciente de la seguridad social (ss) o de seguro privado (sp)'}", status=200, mimetype='application/json')
        
      filas_afectadas = cur.rowcount
      conn.commit()

      if filas_afectadas != 0:
        return Response("{'msg': 'Registro actualizado correctamente'}", status=200, mimetype='application/json')
      return Response("{'msg': 'Algo a ido mal en la actualización, revisa los parametros de la consulta'}", status=404, mimetype='application/json') 
    except:
      return Response("{'msg': 'Error al actualizar la cita del paciente, revisa el body de tu petición'}", status=404, mimetype='application/json')
  else:
    return Response("{'msg': 'Verbo no valido'}", status=404, mimetype='application/json')