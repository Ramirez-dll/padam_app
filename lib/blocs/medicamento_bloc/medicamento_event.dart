part of 'medicamento_bloc.dart';

/// Eventos del BLoC de Medicamento
/// 
/// Los eventos representan las acciones que la UI puede solicitar
/// al BLoC para gestionar los medicamentos.

@immutable
abstract class MedicamentoEvent extends Equatable {
  const MedicamentoEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar la lista de medicamentos de un usuario
/// Parámetros:
///   - idUsuario: ID del usuario cuyos medicamentos se cargarán
class CargarMedicamentos extends MedicamentoEvent {
  final int idUsuario;
  const CargarMedicamentos(this.idUsuario);

  @override
  List<Object?> get props => [idUsuario];
}

/// Evento para agregar un nuevo medicamento
/// Parámetros:
///   - medicamento: Objeto Medicamento completo a agregar
class AgregarMedicamento extends MedicamentoEvent {
  final Medicamento medicamento;
  const AgregarMedicamento(this.medicamento);

  @override
  List<Object?> get props => [medicamento];
}

/// Evento para actualizar un medicamento existente
/// Parámetros:
///   - medicamento: Objeto Medicamento con los datos actualizados
class ActualizarMedicamento extends MedicamentoEvent {
  final Medicamento medicamento;
  const ActualizarMedicamento(this.medicamento);

  @override
  List<Object?> get props => [medicamento];
}

/// Evento para eliminar un medicamento
/// Parámetros:
///   - idMedicamento: ID del medicamento a eliminar
///   - idUsuario: ID del usuario (para recargar la lista correcta)
class EliminarMedicamento extends MedicamentoEvent {
  final int idMedicamento;
  final int idUsuario; // Necesitamos el idUsuario para recargar la lista
  const EliminarMedicamento(this.idMedicamento, this.idUsuario);

  @override
  List<Object?> get props => [idMedicamento, idUsuario];
}