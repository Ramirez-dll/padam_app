import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Servicio para almacenamiento persistente de datos usando SharedPreferences
// 
// Responsabilidades:
// - Gestiona el almacenamiento de medicamentos y registros de toma
// - Proporciona serializacion/deserializacion JSON
// - Maneja errores de almacenamiento y carga
class StorageService {
  static const String _medicamentosKey = 'medicamentos';

  // Guarda la lista de medicamentos en SharedPreferences como JSON
  // Parametros:
  //   - medicamentos: Lista de medicamentos a guardar
  static Future<void> guardarMedicamentos(List<Map<String, dynamic>> medicamentos) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convertir lista a JSON string
    final medicamentosJson = medicamentos.map((med) => _medicamentoToMap(med)).toList();
    await prefs.setString(_medicamentosKey, jsonEncode(medicamentosJson));
    
    print('Medicamentos guardados en persistencia: ${medicamentos.length}');
  }

  // Carga la lista de medicamentos desde SharedPreferences
  // Retorna: Lista de medicamentos o lista vacia si no hay datos
  static Future<List<Map<String, dynamic>>> cargarMedicamentos() async {
    final prefs = await SharedPreferences.getInstance();
    final medicamentosJson = prefs.getString(_medicamentosKey);
    
    if (medicamentosJson == null) {
      print('No hay medicamentos guardados en persistencia');
      return [];
    }
    
    try {
      final lista = jsonDecode(medicamentosJson) as List;
      final medicamentos = lista.map((item) => _mapToMedicamento(item as Map<String, dynamic>)).toList();
      print('Medicamentos cargados desde persistencia: ${medicamentos.length}');
      return medicamentos;
    } catch (e) {
      print('Error al cargar medicamentos: $e');
      return [];
    }
  }

  // Convierte un mapa de medicamento a formato estandarizado para almacenamiento
  static Map<String, dynamic> _medicamentoToMap(Map<String, dynamic> medicamento) {
    return {
      'id_medicamento': medicamento['id_medicamento'],
      'id_usuario': medicamento['id_usuario'],
      'nombre_med': medicamento['nombre_med'],
      'categoria_med': medicamento['categoria_med'],
      'horario_med': medicamento['horario_med'],
      'dias_semana': medicamento['dias_semana'],
      'imagen_url': medicamento['imagen_url'],
      'activo': medicamento['activo'],
    };
  }

  // Convierte un mapa almacenado de vuelta a formato de medicamento
  static Map<String, dynamic> _mapToMedicamento(Map<String, dynamic> map) {
    return {
      'id_medicamento': map['id_medicamento'],
      'id_usuario': map['id_usuario'],
      'nombre_med': map['nombre_med'],
      'categoria_med': map['categoria_med'],
      'horario_med': map['horario_med'],
      'dias_semana': map['dias_semana'],
      'imagen_url': map['imagen_url'],
      'activo': map['activo'],
    };
  }

  static const String _registrosTomaKey = 'registros_toma';

  // Guarda la lista de registros de toma en SharedPreferences
  // Parametros:
  //   - registros: Lista de registros de toma a guardar
  static Future<void> guardarRegistrosToma(List<Map<String, dynamic>> registros) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registrosTomaKey, jsonEncode(registros));
    print('Registros de toma guardados: ${registros.length}');
  }

  // Carga la lista de registros de toma desde SharedPreferences
  // Retorna: Lista de registros de toma o lista vacia si no hay datos
  static Future<List<Map<String, dynamic>>> cargarRegistrosToma() async {
    final prefs = await SharedPreferences.getInstance();
    final registrosJson = prefs.getString(_registrosTomaKey);
    
    if (registrosJson == null) {
      return [];
    }
    
    try {
      final lista = jsonDecode(registrosJson) as List;
      return lista.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error al cargar registros de toma: $e');
      return [];
    }
  }
}