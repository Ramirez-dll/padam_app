import 'package:equatable/equatable.dart';

// Modelo que representa un usuario del sistema
// 
// Informacion gestionada:
// - Datos personales y demograficos
// - Credenciales de acceso (PIN)
// - Informacion de registro y contacto
// - Compatible con datos del CESFAM/PADAM
class Usuario extends Equatable {
  final int? idUsuario;           // ID unico del usuario
  final String nombreUsu;         // Nombre completo del usuario
  final String nombreUsuario;     // Nombre de usuario para login
  final DateTime fechaNac;        // Fecha de nacimiento
  final String genero;            // Genero: "Masculino", "Femenino", etc.
  final String pin;               // PIN de acceso (4 digitos)
  final DateTime fechaRegistro;   // Fecha de registro en el sistema
  final String? rut;              // RUT opcional (formato chileno)
  final String? direccion;        // Direccion opcional

  const Usuario({
    this.idUsuario,
    required this.nombreUsu,
    required this.nombreUsuario,
    required this.fechaNac,
    required this.genero,
    required this.pin,
    required this.fechaRegistro,
    this.rut,
    this.direccion,
  });

  // Convierte el objeto Usuario a Map para base de datos
  // Las fechas se convierten a formato ISO8601
  Map<String, dynamic> toMap() {
    return {
      'id_usuario': idUsuario,
      'nombre_usu': nombreUsu,
      'nombre_usuario': nombreUsuario,
      'fecha_nac': fechaNac.toIso8601String(),
      'genero': genero,
      'pin': pin,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'rut': rut,
      'direccion': direccion,
    };
  }

  // Crea un objeto Usuario desde un Map de base de datos
  // Incluye compatibilidad hacia atras para nombre_usuario
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['id_usuario'],
      nombreUsu: map['nombre_usu'],
      nombreUsuario: map['nombre_usuario'] ?? map['nombre_usu'], // Compatibilidad
      fechaNac: DateTime.parse(map['fecha_nac']),
      genero: map['genero'],
      pin: map['pin'],
      fechaRegistro: DateTime.parse(map['fecha_registro']),
      rut: map['rut'],
      direccion: map['direccion'],
    );
  }

  // Crea una copia del usuario con algunos campos modificados
  // Util para actualizaciones de perfil
  Usuario copyWith({
    int? idUsuario,
    String? nombreUsu,
    String? nombreUsuario,
    DateTime? fechaNac,
    String? genero,
    String? pin,
    DateTime? fechaRegistro,
    String? rut,
    String? direccion,
  }) {
    return Usuario(
      idUsuario: idUsuario ?? this.idUsuario,
      nombreUsu: nombreUsu ?? this.nombreUsu,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      fechaNac: fechaNac ?? this.fechaNac,
      genero: genero ?? this.genero,
      pin: pin ?? this.pin,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      rut: rut ?? this.rut,
      direccion: direccion ?? this.direccion,
    );
  }

  // Definicion de igualdad para Equatable
  @override
  List<Object?> get props => [
    idUsuario,
    nombreUsu,
    nombreUsuario,
    fechaNac,
    genero,
    pin,
    fechaRegistro,
    rut,
    direccion,
  ];
}