import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Servicio para la gestion de la base de datos SQLite
// 
// Responsabilidades:
// - Inicializacion y configuracion de la base de datos
// - Gestion de migraciones entre versiones
// - Creacion de tablas y esquemas
// - Proporciona acceso unificado a la instancia de base de datos
class DatabaseService {
  // Implementacion del patron Singleton para una unica instancia
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  // Propiedad getter para acceder a la base de datos
  // Inicializa la base de datos si no existe
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa la base de datos creandola si no existe
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'padam_database.db');
    
    // TEMPORAL: Borrar la base de datos existente para forzar recreación
    // await deleteDatabase(path);
    
    return await openDatabase(
      path,
      version: 2, // Version actual del esquema
      onCreate: _createTables, // Ejecutar al crear por primera vez
      onUpgrade: _migrateDatabase, // Ejecutar al actualizar version
    );
  }

  // Maneja las migraciones entre versiones de la base de datos
  // Parametros:
  //   - db: Instancia de la base de datos
  //   - oldVersion: Version anterior
  //   - newVersion: Version nueva
  Future<void> _migrateDatabase(Database db, int oldVersion, int newVersion) async {
    print('Migrando base de datos de v$oldVersion a v$newVersion...');
    
    // Migracion de version 1 a version 2
    if (oldVersion < 2) {
      try {
        // Agregar nueva columna nombre_usuario
        await db.execute('ALTER TABLE usuario ADD COLUMN nombre_usuario TEXT');
        
        // Para usuarios existentes, copiar nombre_usu a nombre_usuario
        final usuarios = await db.query('usuario');
        for (var usuario in usuarios) {
          await db.update(
            'usuario',
            {'nombre_usuario': usuario['nombre_usu']},
            where: 'id_usuario = ?',
            whereArgs: [usuario['id_usuario']],
          );
        }
        print('Migración v1->v2 completada');
      } catch (e) {
        print('Error en migración: $e');
      }
    }
  }

  // Crea todas las tablas necesarias para la aplicacion
  // Parametros:
  //   - db: Instancia de la base de datos
  //   - version: Version del esquema
  Future<void> _createTables(Database db, int version) async {
    // Tabla usuario con campos actualizados
    await db.execute('''
      CREATE TABLE usuario(
        id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_usu TEXT NOT NULL,         
        nombre_usuario TEXT NOT NULL,     
        fecha_nac TEXT NOT NULL,         
        genero TEXT NOT NULL,             
        pin TEXT NOT NULL,                
        fecha_registro TEXT NOT NULL,     
        rut TEXT,                         
        direccion TEXT                     
      )
    ''');

    // Tabla medicamento
    await db.execute('''
      CREATE TABLE medicamento(
        id_medicamento INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER NOT NULL,      
        nombre_med TEXT NOT NULL,       
        categoria_med TEXT,              
        horario_med TEXT NOT NULL,       
        dias_semana TEXT NOT NULL,       
        imagen_url TEXT,                   
        activo INTEGER NOT NULL DEFAULT 1, 
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
      )
    ''');

    // Nota: Otras tablas (como registro_toma) se agregaran posteriormente
    print("Base de datos creada exitosamente");
  }
}