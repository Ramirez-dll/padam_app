import 'package:padam_app/models/registro_toma.dart';
import 'package:padam_app/services/storage_service.dart';

// Repository para la gestion de registros de toma de medicamentos
// 
// Responsabilidades:
// - Gestiona el historial de tomas de medicamentos
// - Proporciona consultas por medicamento y fecha
// - Calcula estados de adherencia terapeutica
// - Sincroniza con almacenamiento persistente
class RegistroTomaRepository {
  List<RegistroToma> _registros = [];

  RegistroTomaRepository() {
    _cargarRegistros(); // Carga inicial automatica
  }

  // Carga todos los registros desde el almacenamiento persistente
  Future<void> _cargarRegistros() async {
    try {
      final registrosData = await StorageService.cargarRegistrosToma();
      _registros = registrosData.map((data) => RegistroToma.fromMap(data)).toList();
      print('Registros de toma cargados: ${_registros.length}');
    } catch (e) {
      print('Error al cargar registros: $e');
      _registros = []; // Inicializar lista vacia en caso de error
    }
  }

  // Guarda todos los cambios en el almacenamiento persistente
  Future<void> _guardarCambios() async {
    try {
      final registrosData = _registros.map((reg) => reg.toMap()).toList();
      await StorageService.guardarRegistrosToma(registrosData);
    } catch (e) {
      print('Error al guardar registros: $e');
    }
  }

  // Obtiene todos los registros de un medicamento especifico
  // Parametros:
  //   - idMedicamento: ID del medicamento
  // Retorna: Lista de registros filtrada por medicamento
  Future<List<RegistroToma>> obtenerRegistrosPorMedicamento(int idMedicamento) async {
    return _registros
        .where((reg) => reg.idMedicamento == idMedicamento)
        .toList();
  }

  // Obtiene registros de un usuario para una fecha especifica
  // Nota: Actualmente filtra solo por fecha, no por usuario
  // Parametros:
  //   - idUsuario: ID del usuario (no utilizado actualmente)
  //   - fecha: Fecha para filtrar (opcional, por defecto hoy)
  // Retorna: Lista de registros del dia
  Future<List<RegistroToma>> obtenerRegistrosPorUsuario(int idUsuario, {DateTime? fecha}) async {
    // Por simplicidad, actualmente solo filtra por fecha
    // En una implementacion completa, se relacionaria medicamento -> usuario
    final fechaFiltro = fecha ?? DateTime.now();
    
    return _registros
        .where((reg) => 
          reg.fechaHoraPlanificada.year == fechaFiltro.year &&
          reg.fechaHoraPlanificada.month == fechaFiltro.month &&
          reg.fechaHoraPlanificada.day == fechaFiltro.day)
        .toList();
  }

  // Registra una nueva toma de medicamento
  // Parametros:
  //   - registro: Objeto RegistroToma a guardar
  // Retorna: ID asignado al registro
  Future<int> registrarToma(RegistroToma registro) async {
    try {
      // Generar ID unico basado en timestamp
      final idRegistro = DateTime.now().millisecondsSinceEpoch;
      final nuevoRegistro = registro.copyWith(idRegistro: idRegistro);
      
      // Agregar a la lista en memoria
      _registros.add(nuevoRegistro);
      print('Registro de toma guardado: ${nuevoRegistro.estado}');
      
      // Persistir cambios
      await _guardarCambios();
      return idRegistro;
    } catch (e) {
      print('Error al registrar toma: $e');
      rethrow;
    }
  }

  // Obtiene el estado de toma de un medicamento para el dia actual
  // Parametros:
  //   - idMedicamento: ID del medicamento a consultar
  // Retorna: Estado de la toma (tomado/omitido/pospuesto) o null si no hay registro
  Future<String?> obtenerEstadoTomaHoy(int idMedicamento) async {
    final hoy = DateTime.now();
    
    // Filtrar registros del medicamento para hoy
    final registrosHoy = _registros.where((reg) =>
      reg.idMedicamento == idMedicamento &&
      reg.fechaHoraPlanificada.year == hoy.year &&
      reg.fechaHoraPlanificada.month == hoy.month &&
      reg.fechaHoraPlanificada.day == hoy.day).toList();

    if (registrosHoy.isEmpty) return null;
    
    // Devolver el ultimo estado registrado hoy (mas reciente)
    registrosHoy.sort((a, b) => b.fechaHoraRegistro.compareTo(a.fechaHoraRegistro));
    return registrosHoy.first.estado;
  }
}

// Extension para agregar funcionalidad copyWith al modelo RegistroToma
// Permite crear copias modificadas de objetos RegistroToma
extension on RegistroToma {
  RegistroToma copyWith({
    int? idRegistro,
    int? idMedicamento,
    DateTime? fechaHoraPlanificada,
    DateTime? fechaHoraRegistro,
    String? estado,
    String? observaciones,
  }) {
    return RegistroToma(
      idRegistro: idRegistro ?? this.idRegistro,
      idMedicamento: idMedicamento ?? this.idMedicamento,
      fechaHoraPlanificada: fechaHoraPlanificada ?? this.fechaHoraPlanificada,
      fechaHoraRegistro: fechaHoraRegistro ?? this.fechaHoraRegistro,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}