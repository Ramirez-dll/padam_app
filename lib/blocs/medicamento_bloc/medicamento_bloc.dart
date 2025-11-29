import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart'; 
import 'package:meta/meta.dart';
import 'package:padam_app/models/medicamento.dart';
import 'package:padam_app/repositories/medicamento_repository.dart';
import 'package:padam_app/services/notification_service.dart';

part 'medicamento_event.dart';
part 'medicamento_state.dart';

/// BLoC para la gestión completa del ciclo de vida de los medicamentos
/// 
/// Responsabilidades:
/// - Cargar lista de medicamentos del usuario
/// - Agregar nuevos medicamentos con recordatorios
/// - Actualizar información de medicamentos existentes
/// - Eliminar medicamentos y cancelar sus recordatorios
/// - Sincronizar con notificaciones push
class MedicamentoBloc extends Bloc<MedicamentoEvent, MedicamentoState> {
  final MedicamentoRepository medicamentoRepository;

  MedicamentoBloc({required this.medicamentoRepository}) : super(MedicamentoInitial()) {
    // Registro de todos los eventos manejados por este BLoC
    on<CargarMedicamentos>(_onCargarMedicamentos);
    on<AgregarMedicamento>(_onAgregarMedicamento);
    on<ActualizarMedicamento>(_onActualizarMedicamento);
    on<EliminarMedicamento>(_onEliminarMedicamento);
  }

  /// Carga todos los medicamentos de un usuario específico
  /// Evento: CargarMedicamentos
  /// Emite: MedicamentoCargado (éxito) o MedicamentoError (fallo)
  Future<void> _onCargarMedicamentos(
    CargarMedicamentos event,
    Emitter<MedicamentoState> emit,
  ) async {
    emit(MedicamentoLoading());
    try {
      final medicamentos = await medicamentoRepository.obtenerMedicamentos(event.idUsuario);
      // Emitir MedicamentoCargado aquí
      emit(MedicamentoCargado(medicamentos));
    } catch (e) {
      emit(MedicamentoError('Error al cargar medicamentos: $e'));
    }
  }

  /// Agrega un nuevo medicamento y programa sus recordatorios
  /// Evento: AgregarMedicamento
  /// Acciones: 
  ///   - Guarda en base de datos
  ///   - Programa notificaciones recurrentes
  ///   - Recarga la lista actualizada
  Future<void> _onAgregarMedicamento(
    AgregarMedicamento event,
    Emitter<MedicamentoState> emit,
  ) async {
    try {
      // Guardar el medicamento en la base de datos
      final idMedicamento = await medicamentoRepository.guardarMedicamento(event.medicamento);
      
      print('💊 Medicamento guardado: ${event.medicamento.nombreMed} (ID: $idMedicamento)');
      
      // Programar notificación CON IMAGEN
      await NotificationService.programarRecordatorioMedicamento(
        nombreMedicamento: event.medicamento.nombreMed,
        hora: event.medicamento.horarioMed.hour,
        minuto: event.medicamento.horarioMed.minute,
        diasSemana: event.medicamento.diasSemana.split(','),
        idMedicamento: idMedicamento,
        imagenUrl: event.medicamento.imagenUrl, // PASAR LA IMAGEN
      );
      
      // Recargar la lista completa para reflejar cambios
      final medicamentos = await medicamentoRepository.obtenerMedicamentos(event.medicamento.idUsuario);
      emit(MedicamentoCargado(medicamentos));
      
    } catch (e) {
      print('❌ Error al agregar medicamento: $e');
      emit(MedicamentoError('Error al agregar medicamento: $e'));
    }
  }

  /// Actualiza la información de un medicamento existente
  /// Evento: ActualizarMedicamento
  /// Acciones:
  ///   - Actualiza en base de datos
  ///   - Recarga la lista actualizada
  Future<void> _onActualizarMedicamento(
    ActualizarMedicamento event,
    Emitter<MedicamentoState> emit,
  ) async {
    try {
      await medicamentoRepository.actualizarMedicamento(event.medicamento);
      
      // Recargar la lista después de actualizar
      final medicamentos = await medicamentoRepository.obtenerMedicamentos(event.medicamento.idUsuario);
      emit(MedicamentoCargado(medicamentos));
      
    } catch (e) {
      emit(MedicamentoError('Error al actualizar medicamento: $e'));
    }
  }

  /// Elimina un medicamento y cancela sus recordatorios
  /// Evento: EliminarMedicamento
  /// Acciones:
  ///   - Cancela notificaciones programadas
  ///   - Elimina de base de datos
  ///   - Recarga la lista actualizada
  Future<void> _onEliminarMedicamento(
    EliminarMedicamento event,
    Emitter<MedicamentoState> emit,
  ) async {
    try {
      // CANCELAR RECORDATORIO antes de eliminar
      await NotificationService.cancelarRecordatorio(event.idMedicamento);
      
      // Eliminar medicamento de la base de datos
      await medicamentoRepository.eliminarMedicamento(event.idMedicamento);
      
      // Recargar la lista después de eliminar
      final medicamentos = await medicamentoRepository.obtenerMedicamentos(event.idUsuario);
      emit(MedicamentoCargado(medicamentos));
      
    } catch (e) {
      emit(MedicamentoError('Error al eliminar medicamento: $e'));
    }
  }
}