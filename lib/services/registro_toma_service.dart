import 'package:padam_app/models/registro_toma.dart';
import 'package:padam_app/repositories/registro_toma_repository.dart';

// Servicio para la gestion de registros de toma de medicamentos
// 
// Responsabilidades:
// - Proporciona metodos de alto nivel para registrar diferentes tipos de tomas
// - Encapsula la logica de creacion de objetos RegistroToma
// - Maneja errores y proporciona logs informativos
class RegistroTomaService {
  final RegistroTomaRepository _repository = RegistroTomaRepository();

  // Registra una toma confirmada de medicamento
  // Parametros:
  //   - idMedicamento: ID del medicamento tomado
  //   - nombreMedicamento: Nombre del medicamento (para logs)
  Future<void> registrarTomaConfirmada({
    required int idMedicamento,
    required String nombreMedicamento,
  }) async {
    try {
      final registro = RegistroToma(
        idMedicamento: idMedicamento,
        fechaHoraPlanificada: DateTime.now(),
        fechaHoraRegistro: DateTime.now(),
        estado: 'tomado',
        observaciones: 'Toma confirmada desde notificación',
      );
      
      await _repository.registrarToma(registro);
      print('TOMA CONFIRMADA registrada en BD: $nombreMedicamento');
    } catch (e) {
      print('Error registrando toma confirmada: $e');
    }
  }

  // Registra una omision de toma de medicamento
  // Parametros:
  //   - idMedicamento: ID del medicamento omitido
  //   - nombreMedicamento: Nombre del medicamento (para logs)
  Future<void> registrarOmision({
    required int idMedicamento,
    required String nombreMedicamento,
  }) async {
    try {
      final registro = RegistroToma(
        idMedicamento: idMedicamento,
        fechaHoraPlanificada: DateTime.now(),
        fechaHoraRegistro: DateTime.now(),
        estado: 'omitido',
        observaciones: 'Toma omitida desde notificación',
      );
      
      await _repository.registrarToma(registro);
      print('OMISIÓN registrada en BD: $nombreMedicamento');
    } catch (e) {
      print('Error registrando omisión: $e');
    }
  }

  // Registra una postergacion de toma de medicamento
  // Parametros:
  //   - idMedicamento: ID del medicamento pospuesto
  //   - nombreMedicamento: Nombre del medicamento (para logs)
  Future<void> registrarPostergacion({
    required int idMedicamento,
    required String nombreMedicamento,
  }) async {
    try {
      final registro = RegistroToma(
        idMedicamento: idMedicamento,
        fechaHoraPlanificada: DateTime.now(),
        fechaHoraRegistro: DateTime.now(),
        estado: 'pospuesto',
        observaciones: 'Toma pospuesta desde notificación',
      );
      
      await _repository.registrarToma(registro);
      print('POSTERGACIÓN registrada en BD: $nombreMedicamento');
    } catch (e) {
      print('Error registrando postergación: $e');
    }
  }
}