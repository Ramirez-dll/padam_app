part of 'registro_toma_bloc.dart';

// Estados del BLoC de RegistroToma
// 
// Representan los diferentes estados en los que puede estar
// el registro y consulta de tomas de medicamentos

@immutable
abstract class RegistroTomaState extends Equatable {
  const RegistroTomaState();
}

// Estado inicial - BLoC listo pero sin accion ejecutada
class RegistroTomaInitial extends RegistroTomaState {
  @override
  List<Object?> get props => [];
}

// Estado de carga - Operacion en progreso
class RegistroTomaLoading extends RegistroTomaState {
  @override
  List<Object?> get props => [];
}

// Estado de toma registrada exitosamente
// Parametros:
//   - registro: El objeto RegistroToma que fue guardado
class TomaRegistrada extends RegistroTomaState {
  final RegistroToma registro;

  const TomaRegistrada(this.registro);

  @override
  List<Object?> get props => [registro];
}

// Estado con mapa de estados de todos los medicamentos del usuario
// Parametros:
//   - estados: Mapa donde la clave es idMedicamento y el valor es el estado
//   Util para mostrar badges o indicadores en la lista de medicamentos
class EstadosTomaCargados extends RegistroTomaState {
  final Map<int, String> estados; // idMedicamento -> estado

  const EstadosTomaCargados(this.estados);

  @override
  List<Object?> get props => [estados];
}

// Estado con el estado de un medicamento especifico
// Parametros:
//   - idMedicamento: ID del medicamento consultado
//   - estado: Estado de la toma (puede ser null si no hay registro)
class EstadoTomaObtenido extends RegistroTomaState {
  final int idMedicamento;
  final String? estado;

  const EstadoTomaObtenido(this.idMedicamento, this.estado);

  @override
  List<Object?> get props => [idMedicamento, estado];
}

// Estado de error en alguna operacion
// Parametros:
//   - mensaje: Descripcion del error ocurrido
class RegistroTomaError extends RegistroTomaState {
  final String mensaje;

  const RegistroTomaError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}