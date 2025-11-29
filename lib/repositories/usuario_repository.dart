import 'package:padam_app/models/usuario.dart';
import 'package:padam_app/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

// Repository para la gestion de datos de usuarios
// 
// Responsabilidades:
// - Gestiona el ciclo de vida completo de los usuarios
// - Proporciona autenticacion y verificacion de credenciales
// - Maneja consultas de existencia y busqueda de usuarios
// - Utiliza SQLite para persistencia robusta
class UsuarioRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Guarda un nuevo usuario en la base de datos
  // Parametros:
  //   - usuario: Objeto Usuario a guardar
  // Retorna: Usuario con ID asignado
  Future<Usuario> guardarUsuario(Usuario usuario) async {
    print('Guardando usuario en BD: ${usuario.nombreUsu}');
    print('Fecha nacimiento a guardar: ${usuario.fechaNac}');
    
    final db = await _databaseService.database;
    
    // Insertar usuario en la base de datos
    final id = await db.insert(
      'usuario',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplazar si existe conflicto
    );
    
    print('Usuario guardado con ID: $id');
    return usuario.copyWith(idUsuario: id);
  }

  // Obtiene un usuario por su ID
  // Parametros:
  //   - id: ID del usuario a buscar
  // Retorna: Usuario encontrado o null si no existe
  Future<Usuario?> obtenerUsuarioPorId(int id) async {
    final db = await _databaseService.database;
    
    final maps = await db.query(
      'usuario',
      where: 'id_usuario = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  // Obtiene el ultimo usuario registrado en el sistema
  // Util para pre-cargar el login cuando hay un solo usuario
  // Retorna: Ultimo usuario registrado o null si no hay usuarios
  Future<Usuario?> obtenerUltimoUsuario() async {
    final db = await _databaseService.database;
    
    final maps = await db.query(
      'usuario',
      orderBy: 'id_usuario DESC', // Ordenar por ID descendente
      limit: 1, // Solo el ultimo registro
    );
    
    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  // Verifica si existe al menos un usuario en el sistema
  // Util para determinar si mostrar formulario de registro o login
  // Retorna: true si existe al menos un usuario, false en caso contrario
  Future<bool> existeUsuario() async {
    final db = await _databaseService.database;
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM usuario'
    );
    
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  // Verifica si un PIN existe en la base de datos
  // Parametros:
  //   - pin: PIN a verificar
  // Retorna: true si el PIN existe, false en caso contrario
  Future<bool> verificarPin(String pin) async {
    final db = await _databaseService.database;
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM usuario WHERE pin = ?',
      [pin],
    );
    
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  // Obtiene un usuario por su PIN
  // Parametros:
  //   - pin: PIN del usuario a buscar
  // Retorna: Usuario encontrado o null si no existe
  Future<Usuario?> obtenerUsuarioPorPin(String pin) async {
    final db = await _databaseService.database;
    
    final maps = await db.query(
      'usuario',
      where: 'pin = ?',
      whereArgs: [pin],
    );
    
    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  // Verifica las credenciales de login (nombre de usuario y PIN)
  // Parametros:
  //   - nombreUsuario: Nombre de usuario
  //   - pin: PIN del usuario
  // Retorna: true si las credenciales son validas, false en caso contrario
  Future<bool> verificarLogin(String nombreUsuario, String pin) async {
    print('Verificando login: usuario="$nombreUsuario", pin="$pin"');
    
    final db = await _databaseService.database;
    
    // Consulta case-insensitive para nombre de usuario
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM usuario WHERE LOWER(nombre_usuario) = LOWER(?) AND pin = ?',
      [nombreUsuario, pin],
    );
    
    final count = Sqflite.firstIntValue(result) ?? 0;
    print('Resultado de la consulta: $count usuarios encontrados');
    
    return count > 0;
  }

  // Obtiene un usuario por su nombre de usuario
  // Parametros:
  //   - nombreUsuario: Nombre de usuario a buscar
  // Retorna: Usuario encontrado o null si no existe
  Future<Usuario?> obtenerUsuarioPorNombreUsuario(String nombreUsuario) async {
    print('Buscando usuario por nombre: "$nombreUsuario"');
    
    final db = await _databaseService.database;
    
    // Busqueda case-insensitive
    final maps = await db.query(
      'usuario',
      where: 'LOWER(nombre_usuario) = LOWER(?)',
      whereArgs: [nombreUsuario],
    );
    
    print('Usuarios encontrados: ${maps.length}');
    if (maps.isNotEmpty) {
      print('Usuario encontrado: ${maps.first}');
      return Usuario.fromMap(maps.first);
    }
    print('Usuario no encontrado');
    return null;
  }

  // Verifica si un nombre de usuario ya existe en el sistema
  // Util para validar unicidad durante el registro
  // Parametros:
  //   - nombreUsuario: Nombre de usuario a verificar
  // Retorna: true si el nombre de usuario ya existe, false en caso contrario
  Future<bool> existeNombreUsuario(String nombreUsuario) async {
    final db = await _databaseService.database;
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM usuario WHERE nombre_usuario = ?',
      [nombreUsuario],
    );
    
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}