import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:padam_app/models/registro_toma.dart';
import 'package:padam_app/repositories/registro_toma_repository.dart';

part 'registro_toma_event.dart';
part 'registro_toma_state.dart';

// BLoC para la gestion de registros de toma de medicamentos
// 
// Responsabilidades:
// - Registrar cuando un usuario toma un medicamento
// - Cargar el historial de registros del dia
// - Consultar el estado de toma de medicamentos especificos
// - Mantener seguimiento de la adherencia terapeutica
class RegistroTomaBloc extends Bloc<RegistroTomaEvent, RegistroTomaState> {
  final RegistroTomaRepository registroTomaRepository;

  RegistroTomaBloc({required this.registroTomaRepository}) : super(RegistroTomaInitial()) {
    // Registro de eventos manejados por este BLoC
    on<RegistrarToma>(_onRegistrarToma);
    on<CargarRegistrosHoy>(_onCargarRegistrosHoy);
    on<ObtenerEstadoTomaHoy>(_onObtenerEstadoTomaHoy);
  }

  // Registra una toma de medicamento con estado y observaciones
  // Evento: RegistrarToma
  // Emite: TomaRegistrada (exito) o RegistroTomaError (fallo)
  Future<void> _onRegistrarToma(
    RegistrarToma event,
    Emitter<RegistroTomaState> emit,
  ) async {
    try {
      final ahora = DateTime.now();
      // Crear registro con fecha actual y estado proporcionado
      final registro = RegistroToma(
        idMedicamento: event.idMedicamento,
        fechaHoraPlanificada: DateTime(ahora.year, ahora.month, ahora.day, ahora.hour, ahora.minute),
        fechaHoraRegistro: ahora,
        estado: event.estado, // "tomado", "omitido", etc.
        observaciones: event.observaciones,
      );

      await registroTomaRepository.registrarToma(registro);
      emit(TomaRegistrada(registro));
      
      print('Toma registrada: ${event.estado} para medicamento ${event.idMedicamento}');
    } catch (e) {
      emit(RegistroTomaError('Error al registrar toma: $e'));
    }
  }

  // Carga todos los registros de toma de un usuario para el dia actual
  // Evento: CargarRegistrosHoy
  // Emite: EstadosTomaCargados con mapa de estados por medicamento
  Future<void> _onCargarRegistrosHoy(
    CargarRegistrosHoy event,
    Emitter<RegistroTomaState> emit,
  ) async {
    emit(RegistroTomaLoading());
    try {
      final registros = await registroTomaRepository.obtenerRegistrosPorUsuario(event.idUsuario);
      final estados = <int, String>{};
      
      // Convertir lista de registros a mapa para acceso rapido
      for (final registro in registros) {
        estados[registro.idMedicamento] = registro.estado;
      }
      
      emit(EstadosTomaCargados(estados));
    } catch (e) {
      emit(RegistroTomaError('Error al cargar registros: $e'));
    }
  }

  // Consulta el estado de toma de un medicamento especifico para el dia de hoy
  // Evento: ObtenerEstadoTomaHoy
  // Emite: EstadoTomaObtenido con el estado encontrado (o null si no hay registro)
  Future<void> _onObtenerEstadoTomaHoy(
    ObtenerEstadoTomaHoy event,
    Emitter<RegistroTomaState> emit,
  ) async {
    try {
      final estado = await registroTomaRepository.obtenerEstadoTomaHoy(event.idMedicamento);
      emit(EstadoTomaObtenido(event.idMedicamento, estado));
    } catch (e) {
      emit(RegistroTomaError('Error al obtener estado: $e'));
    }
  }
}