import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// Servicio para programar el reinicio diario del sistema de notificaciones
// 
// Proposito:
// - Programa una notificacion que se active diariamente a las 00:01
// - Permite reiniciar estados del sistema y reprogramar notificaciones
// - Util para mantener la consistencia del sistema de recordatorios
class DailyResetService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Programa una notificacion de reinicio diario para las 00:01 del dia siguiente
  // Esta notificacion podria utilizarse como trigger para resetear estados
  static Future<void> programarReinicioDiario() async {
    print('Programando reinicio diario de notificaciones...');
    
    try {
      // Calcular fecha para mañana a las 00:01
      final manana = tz.TZDateTime.now(tz.local).add(const Duration(days: 1));
      final fechaReinicio = tz.TZDateTime(tz.local, manana.year, manana.month, manana.day, 0, 1);
      
      // Configuracion de la notificacion
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'reinicio_diario',
        'Reinicio Diario',
        channelDescription: 'Reinicio diario del sistema de notificaciones',
        importance: Importance.min, // Importancia minima ya que es un proceso interno
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      // Programar notificacion con modo exacto
      await _notifications.zonedSchedule(
        888888, // ID fijo para la notificacion de reinicio
        'Reinicio Diario',
        'Reiniciando sistema de notificaciones',
        fechaReinicio,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Modo exacto incluso en modo idle
        payload: 'reinicio_diario', // Payload para identificar el tipo de notificacion
      );
      
      print('Reinicio diario programado para: $fechaReinicio');
    } catch (e) {
      print('Error programando reinicio diario: $e');
    }
  }
}