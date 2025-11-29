import 'package:equatable/equatable.dart';

// Modelo que representa un administrador del sistema
// 
// Responsabilidades:
// - Almacena la informacion del personal de salud del CESFAM
// - Gestiona credenciales de acceso al panel web
// - Permite relaciones de supervision con usuarios
class Administrador extends Equatable {
  final int? idAdmin;
  final String nombreAdm;
  final String correoAdm;
  final String contrasenaAdm;

  const Administrador({
    this.idAdmin,
    required this.nombreAdm,
    required this.correoAdm,
    required this.contrasenaAdm,
  });

  // Convierte el objeto Administrador a Map para base de datos
  Map<String, dynamic> toMap() {
    return {
      'id_admin': idAdmin,
      'nombre_adm': nombreAdm,
      'correo_adm': correoAdm,
      'contrasena_adm': contrasenaAdm,
    };
  }

  // Crea un objeto Administrador desde un Map de base de datos
  factory Administrador.fromMap(Map<String, dynamic> map) {
    return Administrador(
      idAdmin: map['id_admin'],
      nombreAdm: map['nombre_adm'],
      correoAdm: map['correo_adm'],
      contrasenaAdm: map['contrasena_adm'],
    );
  }

  // Crea una copia del administrador con algunos campos modificados
  Administrador copyWith({
    int? idAdmin,
    String? nombreAdm,
    String? correoAdm,
    String? contrasenaAdm,
  }) {
    return Administrador(
      idAdmin: idAdmin ?? this.idAdmin,
      nombreAdm: nombreAdm ?? this.nombreAdm,
      correoAdm: correoAdm ?? this.correoAdm,
      contrasenaAdm: contrasenaAdm ?? this.contrasenaAdm,
    );
  }

  @override
  List<Object?> get props => [
    idAdmin,
    nombreAdm,
    correoAdm,
    contrasenaAdm,
  ];
}