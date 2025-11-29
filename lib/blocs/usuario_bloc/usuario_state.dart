part of 'usuario_bloc.dart';

// Estados del BLoC de Usuario
// 
// Representan los diferentes estados en los que puede estar
// el proceso de gestion de usuarios y autenticacion

abstract class UsuarioState extends Equatable {
  const UsuarioState();

  @override
  List<Object> get props => [];
}

// Estado inicial - BLoC listo pero sin accion ejecutada
class UsuarioInitial extends UsuarioState {}

// Estado de carga - Operacion en progreso
class UsuarioLoading extends UsuarioState {}

// Estado de usuario registrado exitosamente
// Parametros:
//   - usuario: El usuario que fue registrado
class UsuarioRegistrado extends UsuarioState {
  final Usuario usuario;
  const UsuarioRegistrado(this.usuario);

  @override
  List<Object> get props => [usuario];
}

// Estado que indica que existe al menos un usuario en el sistema
// Parametros:
//   - usuario: El ultimo usuario encontrado (para pre-cargar login)
class UsuarioExiste extends UsuarioState {
  final Usuario usuario;
  const UsuarioExiste(this.usuario);

  @override
  List<Object> get props => [usuario];
}

// Estado que indica que no existe ningun usuario en el sistema
// Usado para redirigir al flujo de registro
class UsuarioNoExiste extends UsuarioState {}

// Estado con un usuario cargado exitosamente
// Parametros:
//   - usuario: El usuario que fue cargado
class UsuarioCargado extends UsuarioState {
  final Usuario usuario;
  const UsuarioCargado(this.usuario);

  @override
  List<Object> get props => [usuario];
}

// Estado de PIN verificado correctamente
// Parametros:
//   - usuario: El usuario autenticado
class PinCorrecto extends UsuarioState {
  final Usuario usuario;
  const PinCorrecto(this.usuario);

  @override
  List<Object> get props => [usuario];
}

// Estado de PIN incorrecto o credenciales invalidas
// Parametros:
//   - mensaje: Mensaje de error descriptivo
class PinIncorrecto extends UsuarioState {
  final String mensaje;
  const PinIncorrecto(this.mensaje);

  @override
  List<Object> get props => [mensaje];
}

// Estado de error en alguna operacion
// Parametros:
//   - mensaje: Descripcion del error ocurrido
class UsuarioError extends UsuarioState {
  final String mensaje;
  const UsuarioError(this.mensaje);

  @override
  List<Object> get props => [mensaje];
}

// Estado que indica que hay un usuario en sesion activa
// Parametros:
//   - usuario: El usuario que tiene la sesion activa
class UsuarioEnSesion extends UsuarioState {
  final Usuario usuario;
  const UsuarioEnSesion(this.usuario);

  @override
  List<Object> get props => [usuario];
}