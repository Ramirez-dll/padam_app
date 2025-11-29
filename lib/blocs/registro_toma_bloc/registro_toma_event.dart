part of 'registro_toma_bloc.dart';

// Eventos del BLoC de RegistroToma
// 
// Representan las acciones relacionadas con el registro y consulta
// de tomas de medicamentos

@immutable
abstract class RegistroTomaEvent extends Equatable {
  const RegistroTomaEvent();
}

// Evento para registrar que se tomo (o no) un medicamento
// Parametros:
//   - idMedicamento: ID del medicamento a registrar
//   - estado: Estado de la toma ("tomado", "omitido", etc.)
//   - observaciones: Comentarios opcionales sobre la toma
class RegistrarToma extends RegistroTomaEvent {
  final int idMedicamento;
  final String estado;
  final String? observaciones;

  const RegistrarToma(this.idMedicamento, this.estado, {this.observaciones});

  @override
  List<Object?> get props => [idMedicamento, estado, observaciones];
}

// Evento para cargar todos los registros de toma de un usuario
// Parametros:
//   - idUsuario: ID del usuario cuyos registros se cargaran
class CargarRegistrosHoy extends RegistroTomaEvent {
  final int idUsuario;

  const CargarRegistrosHoy(this.idUsuario);

  @override
  List<Object?> get props => [idUsuario];
}

// Evento para consultar el estado de un medicamento especifico
// Parametros:
//   - idMedicamento: ID del medicamento a consultar
class ObtenerEstadoTomaHoy extends RegistroTomaEvent {
  final int idMedicamento;

  const ObtenerEstadoTomaHoy(this.idMedicamento);

  @override
  List<Object?> get props => [idMedicamento];
}