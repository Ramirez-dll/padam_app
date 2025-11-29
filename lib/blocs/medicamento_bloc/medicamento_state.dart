part of 'medicamento_bloc.dart';

/// Estados del BLoC de Medicamento
/// 
/// Representan los diferentes estados en los que puede estar
/// la gestión de medicamentos en la aplicación.

@immutable
abstract class MedicamentoState extends Equatable {
  const MedicamentoState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - BLoC listo pero sin acción ejecutada
class MedicamentoInitial extends MedicamentoState {}

/// Estado de carga - Operación en progreso
class MedicamentoLoading extends MedicamentoState {}

/// Estado de medicamento agregado exitosamente
/// Parámetros:
///   - medicamento: El medicamento que fue agregado
/// NOTA: Este estado NO se está usando actualmente en el BLoC
///    Se emite MedicamentoCargado en su lugar después de agregar
class MedicamentoAgregado extends MedicamentoState {
  final Medicamento medicamento;
  const MedicamentoAgregado(this.medicamento);

  @override
  List<Object?> get props => [medicamento];
}

/// Estado con lista de medicamentos cargada exitosamente
/// Parámetros:
///   - medicamentos: Lista completa de medicamentos del usuario
/// ESTADO PRINCIPAL: Se emite después de cargar, agregar, actualizar o eliminar
class MedicamentoCargado extends MedicamentoState {
  final List<Medicamento> medicamentos;
  const MedicamentoCargado(this.medicamentos);

  @override
  List<Object?> get props => [medicamentos];
}

/// Estado de medicamento actualizado exitosamente
/// Parámetros:
///   - medicamento: El medicamento que fue actualizado
/// NOTA: Este estado NO se está usando actualmente en el BLoC
///    Se emite MedicamentoCargado en su lugar después de actualizar
class MedicamentoActualizado extends MedicamentoState {
  final Medicamento medicamento;
  const MedicamentoActualizado(this.medicamento);

  @override
  List<Object?> get props => [medicamento];
}

/// Estado de medicamento eliminado exitosamente
/// Parámetros:
///   - idMedicamento: ID del medicamento que fue eliminado
/// NOTA: Este estado NO se está usando actualmente en el BLoC
///    Se emite MedicamentoCargado en su lugar después de eliminar
class MedicamentoEliminado extends MedicamentoState {
  final int idMedicamento;
  const MedicamentoEliminado(this.idMedicamento);

  @override
  List<Object?> get props => [idMedicamento];
}

/// Estado de error en alguna operación
/// Parámetros:
///   - mensaje: Descripción del error ocurrido
class MedicamentoError extends MedicamentoState {
  final String mensaje;
  const MedicamentoError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}