part of 'usuario_bloc.dart';

// Eventos del BLoC de Usuario
// 
// Representan las acciones relacionadas con la gestion de usuarios
// y el proceso de autenticacion

abstract class UsuarioEvent extends Equatable {
  const UsuarioEvent();

  @override
  List<Object> get props => [];
}

// Evento para registrar un nuevo usuario en el sistema
// Parametros:
//   - usuario: Objeto Usuario completo con todos los datos
class RegistrarUsuario extends UsuarioEvent {
  final Usuario usuario;
  const RegistrarUsuario(this.usuario);

  @override
  List<Object> get props => [usuario];
}

// Evento para verificar si un PIN corresponde a algun usuario
// Parametros:
//   - pinIngresado: PIN a verificar
class VerificarPin extends UsuarioEvent {
  final String pinIngresado;
  const VerificarPin(this.pinIngresado);

  @override
  List<Object> get props => [pinIngresado];
}

// Evento para verificar si existe algun usuario en el sistema
// No requiere parametros - verifica estado general del sistema
class VerificarUsuarioExistente extends UsuarioEvent {}

// Evento para cargar un usuario especifico por su PIN
// Parametros:
//   - pin: PIN del usuario a cargar
class CargarUsuarioPorPin extends UsuarioEvent {
  final String pin;
  const CargarUsuarioPorPin(this.pin);

  @override
  List<Object> get props => [pin];
}

// Evento para verificar credenciales completas de login
// Parametros:
//   - nombreUsuario: Nombre de usuario
//   - pin: PIN del usuario
class VerificarLogin extends UsuarioEvent {
  final String nombreUsuario;
  final String pin;
  const VerificarLogin(this.nombreUsuario, this.pin);

  @override
  List<Object> get props => [nombreUsuario, pin];
}