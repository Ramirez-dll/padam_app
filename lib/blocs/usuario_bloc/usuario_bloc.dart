import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:padam_app/models/usuario.dart';
import 'package:padam_app/repositories/usuario_repository.dart';
import 'package:padam_app/services/session_service.dart';

part 'usuario_event.dart';
part 'usuario_state.dart';

// BLoC para la gestion completa del ciclo de vida del usuario
// 
// Responsabilidades:
// - Registrar nuevos usuarios en el sistema
// - Verificar credenciales de login (usuario y PIN)
// - Gestionar sesiones de usuario
// - Verificar existencia de usuarios en el dispositivo
// - Cargar informacion de usuario por diferentes criterios
class UsuarioBloc extends Bloc<UsuarioEvent, UsuarioState> {
  final UsuarioRepository _usuarioRepository;

  // Inicializacion del BLoC con el repositorio de usuarios
  UsuarioBloc({required UsuarioRepository usuarioRepository})
      : _usuarioRepository = usuarioRepository,
        super(UsuarioInitial()) {
    // Registro de todos los eventos manejados por este BLoC
    on<RegistrarUsuario>(_onRegistrarUsuario);
    on<VerificarPin>(_onVerificarPin);
    on<VerificarUsuarioExistente>(_onVerificarUsuarioExistente);
    on<CargarUsuarioPorPin>(_onCargarUsuarioPorPin);
    on<VerificarLogin>(_onVerificarLogin);
  }

  // Procesa el registro de un nuevo usuario en el sistema
  // Evento: RegistrarUsuario
  // Acciones:
  //   - Guarda el usuario en la base de datos
  //   - Inicia sesion automaticamente despues del registro
  //   - Emite UsuarioRegistrado con el usuario guardado
  void _onRegistrarUsuario(RegistrarUsuario event, Emitter<UsuarioState> emit) async {
    emit(UsuarioLoading());
    try {
      final usuarioGuardado = await _usuarioRepository.guardarUsuario(event.usuario);
      
      // Iniciar sesion automaticamente despues del registro exitoso
      if (usuarioGuardado.idUsuario != null) {
        await SessionService.guardarUsuarioLogueado(usuarioGuardado.idUsuario!);
      }
      
      emit(UsuarioRegistrado(usuarioGuardado));
    } catch (e) {
      emit(UsuarioError('Error al registrar usuario: $e'));
    }
  }

  // Verifica si un PIN es correcto para algun usuario existente
  // Evento: VerificarPin
  // Emite: PinCorrecto si el PIN existe, PinIncorrecto si no
  void _onVerificarPin(VerificarPin event, Emitter<UsuarioState> emit) async {
    emit(UsuarioLoading());
    try {
      final usuario = await _usuarioRepository.obtenerUsuarioPorPin(event.pinIngresado);
      
      if (usuario != null) {
        // Iniciar sesion al verificar PIN correcto
        if (usuario.idUsuario != null) {
          await SessionService.guardarUsuarioLogueado(usuario.idUsuario!);
        }
        
        emit(PinCorrecto(usuario));
      } else {
        emit(PinIncorrecto('PIN incorrecto'));
      }
    } catch (e) {
      emit(UsuarioError('Error al verificar PIN: $e'));
    }
  }

  // Verifica si existe algun usuario en el sistema y si hay sesion activa
  // Evento: VerificarUsuarioExistente
  // Logica:
  //   1. Primero verifica si hay sesion activa (prioridad)
  //   2. Si no hay sesion, verifica si existe algun usuario
  //   3. Emite estado segun lo encontrado
  void _onVerificarUsuarioExistente(VerificarUsuarioExistente event, Emitter<UsuarioState> emit) async {
    try {
      // Verificar primero si hay usuario en sesion activa
      final usuarioId = await SessionService.obtenerUsuarioLogueadoId();
      
      if (usuarioId != null) {
        final usuario = await _usuarioRepository.obtenerUsuarioPorId(usuarioId);
        if (usuario != null) {
          emit(UsuarioEnSesion(usuario));
          return;
        }
      }
      
      // Si no hay sesion activa, verificar si existe algun usuario en la BD
      final existeUsuario = await _usuarioRepository.existeUsuario();
      
      if (existeUsuario) {
        // Obtener el ultimo usuario para mostrar en el login
        final usuario = await _usuarioRepository.obtenerUltimoUsuario();
        if (usuario != null) {
          emit(UsuarioExiste(usuario));
        } else {
          emit(UsuarioNoExiste());
        }
      } else {
        emit(UsuarioNoExiste());
      }
    } catch (e) {
      emit(UsuarioError('Error al verificar usuario: $e'));
    }
  }

  // Carga un usuario especifico buscando por su PIN
  // Evento: CargarUsuarioPorPin
  // Emite: UsuarioCargado si se encuentra, UsuarioError si no
  void _onCargarUsuarioPorPin(CargarUsuarioPorPin event, Emitter<UsuarioState> emit) async {
    emit(UsuarioLoading());
    try {
      final usuario = await _usuarioRepository.obtenerUsuarioPorPin(event.pin);
      if (usuario != null) {
        emit(UsuarioCargado(usuario));
      } else {
        emit(UsuarioError('No se encontró usuario con ese PIN'));
      }
    } catch (e) {
      emit(UsuarioError('Error al cargar usuario: $e'));
    }
  }

  // Verifica las credenciales de login (nombre de usuario y PIN)
  // Evento: VerificarLogin
  // Logica de autenticacion completa con nombre de usuario y PIN
  void _onVerificarLogin(VerificarLogin event, Emitter<UsuarioState> emit) async {
    print('Iniciando verificación de login...');
    emit(UsuarioLoading());
    
    try {
      final loginValido = await _usuarioRepository.verificarLogin(
        event.nombreUsuario, 
        event.pin
      );
      
      print('Resultado verificación: $loginValido');
      
      if (loginValido) {
        final usuario = await _usuarioRepository.obtenerUsuarioPorNombreUsuario(event.nombreUsuario);
        if (usuario != null) {
          print('Login exitoso para: ${usuario.nombreUsu}');
          // Guardar sesion al login exitoso
          if (usuario.idUsuario != null) {
            await SessionService.guardarUsuarioLogueado(usuario.idUsuario!);
          }
          emit(PinCorrecto(usuario));
        } else {
          print('Error: usuario nulo después de verificación exitosa');
          emit(PinIncorrecto('Error al cargar usuario'));
        }
      } else {
        print('Login fallido');
        emit(PinIncorrecto('Usuario o PIN incorrecto'));
      }
    } catch (e) {
      print('Error en login: $e');
      emit(UsuarioError('Error al verificar login: $e'));
    }
  }
}