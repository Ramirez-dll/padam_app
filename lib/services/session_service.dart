import 'package:shared_preferences/shared_preferences.dart';

// Servicio para la gestion de sesiones de usuario
// 
// Responsabilidades:
// - Maneja el almacenamiento persistente del ID de usuario logueado
// - Proporciona metodos para guardar, obtener y cerrar sesiones
// - Utiliza SharedPreferences para persistencia simple y eficiente
class SessionService {
  static const String _keyUsuarioId = 'usuario_logueado_id';

  // Guarda el ID del usuario que ha iniciado sesion
  // Parametros:
  //   - usuarioId: ID del usuario a guardar en sesion
  static Future<void> guardarUsuarioLogueado(int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUsuarioId, usuarioId);
  }

  // Obtiene el ID del usuario actualmente logueado
  // Retorna: ID del usuario o null si no hay sesion activa
  static Future<int?> obtenerUsuarioLogueadoId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUsuarioId);
  }

  // Cierra la sesion del usuario actual
  // Elimina el ID de usuario almacenado en SharedPreferences
  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuarioId);
  }
}