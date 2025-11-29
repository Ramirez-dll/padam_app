import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// Servicio principal para la gestion de notificaciones de la aplicacion
// 
// Responsabilidades:
// - Inicializacion del sistema de notificaciones
// - Programacion y cancelacion de recordatorios de medicamentos
// - Manejo de respuestas a notificaciones (taps y acciones)
// - Proporciona metodos de prueba para desarrollo
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _inicializado = false;

  // Callback para manejar taps en notificaciones desde cualquier parte de la app
  static Function(int, String)? onNotificacionTap;

  // Inicializa el sistema de notificaciones
  // Parametros:
  //   - onTap: Callback opcional para manejar taps en notificaciones
  static Future<void> initialize({Function(int, String)? onTap}) async {
    if (_inicializado) return;
    
    onNotificacionTap = onTap;
    
    print('Inicializando NotificationService...');
    
    try {
      // Inicializar timezone para notificaciones programadas
      tz.initializeTimeZones();
      
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
      
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Inicializar el plugin con callback para respuestas
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // Crear canal de notificaciones para Android
      await _crearCanalNotificaciones();
      
      _inicializado = true;
      print('NotificationService inicializado correctamente');
      
    } catch (e) {
      print('Error en NotificationService: $e');
    }
  }

  // Maneja la respuesta cuando el usuario toca una notificacion
  static void _onNotificationResponse(NotificationResponse response) {
    print('Notificación tocada:');
    print('   - Payload: ${response.payload}');
    _procesarPayloadForeground(response.payload);
  }

  // Procesa el payload de la notificacion cuando la app esta en primer plano
  // Extrae informacion del medicamento y ejecuta el callback correspondiente
  static void _procesarPayloadForeground(String? payload) {
    if (payload != null && payload.startsWith('medicamento_')) {
      print('Procesando payload: $payload');
      
      // Parsear el payload para extraer ID y nombre del medicamento
      final partes = payload.split('_');
      if (partes.length >= 3) {
        final idMedicamento = int.tryParse(partes[1]);
        final nombreCompleto = partes.sublist(2).join('_');
        
        // Separar nombre de medicamento y URL de imagen
        final partesNombre = nombreCompleto.split('|');
        final nombreMedicamento = partesNombre.first.replaceAll('_', ' ');
        String? imagenUrl;
        
        // Procesar URL de imagen si existe
        if (partesNombre.length > 1) {
          imagenUrl = partesNombre[1].replaceAll('_', '/');
          // Corregir ruta de la imagen para Android
          imagenUrl = imagenUrl.replaceFirst('com.example.padam/app', 'com.example.padam_app');
        }
        
        if (idMedicamento != null) {
          print('Medicamento: $nombreMedicamento');
          print('Imagen: $imagenUrl');
          
          // Ejecutar callback si esta registrado
          if (onNotificacionTap != null) {
            onNotificacionTap!(idMedicamento, nombreMedicamento);
          }
        }
      }
    }
  }

  // Crea el canal de notificaciones para Android
  static Future<void> _crearCanalNotificaciones() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'recordatorio_medicamento',
      'Recordatorios de Medicamentos',
      description: 'Recordatorios para tomar medicamentos',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    await _notifications.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  // Programa recordatorios de medicamentos (actualmente solo notificaciones inmediatas)
  // NOTA: Las notificaciones programadas reales requieren WorkManager
  // Parametros:
  //   - nombreMedicamento: Nombre del medicamento
  //   - hora: Hora programada
  //   - minuto: Minuto programado
  //   - diasSemana: Dias de la semana para repetir
  //   - idMedicamento: ID del medicamento
  //   - imagenUrl: URL de la imagen del medicamento (opcional)
  static Future<void> programarRecordatorioMedicamento({
    required String nombreMedicamento,
    required int hora,
    required int minuto,
    required List<String> diasSemana,
    required int idMedicamento,
    String? imagenUrl,
  }) async {
    print('SIMULANDO programación para: $nombreMedicamento');
    print('Horario simulado: $hora:$minuto');
    print('Días: ${diasSemana.join(', ')}');
    
    // Por ahora, solo mostrar notificacion inmediata para testing
    // Las notificaciones programadas reales requieren WorkManager
    await _mostrarNotificacionMedicamento(
      nombreMedicamento: nombreMedicamento,
      idMedicamento: idMedicamento,
      idMedicamentoReal: idMedicamento,
      imagenUrl: imagenUrl,
    );
    
    print('INFO: Las notificaciones programadas reales se implementarán con WorkManager');
  }

  // Muestra una notificacion inmediata de medicamento
  static Future<void> _mostrarNotificacionMedicamento({
    required String nombreMedicamento,
    required int idMedicamento,
    required int idMedicamentoReal,
    String? imagenUrl,
  }) async {
    // Codificar nombre e imagen para el payload
    final nombreCodificado = nombreMedicamento.replaceAll(' ', '_');
    final imagenCodificada = imagenUrl?.replaceAll('/', '_') ?? '';
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'recordatorio_medicamento',
      'Recordatorios de Medicamentos',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    // Construir payload con informacion del medicamento
    final payload = imagenCodificada.isNotEmpty 
        ? 'medicamento_${idMedicamentoReal}_$nombreCodificado|$imagenCodificada'
        : 'medicamento_${idMedicamentoReal}_$nombreCodificado';

    // Mostrar notificacion inmediata
    await _notifications.show(
      idMedicamento,
      '💊 Hora de: $nombreMedicamento',
      'Toca para registrar la toma',
      details,
      payload: payload,
    );
    
    print('Notificación INMEDIATA mostrada: $nombreMedicamento');
  }

  // Cancela un recordatorio de medicamento
  // Parametros:
  //   - idMedicamento: ID del medicamento cuya notificacion cancelar
  static Future<void> cancelarRecordatorio(int idMedicamento) async {
    await _notifications.cancel(idMedicamento);
    print('Notificación cancelada: $idMedicamento');
  }

  // Metodo de prueba para verificar diferentes metodos de programacion
  static Future<void> probarNotificacionProgramada() async {
    print('Probando DIFERENTES métodos de programación...');
    
    // Probar diferentes metodos de programacion
    await _probarZonedSchedule();    // Metodo 1
    await _probarRepeatInterval();   // Metodo 2
    _mostrarMensajeProgramacion();   // Mensaje informativo
  }

  // Prueba el metodo zonedSchedule basico
  static Future<void> _probarZonedSchedule() async {
    try {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'recordatorio_medicamento',
        'Recordatorios de Medicamentos',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        1001,
        '💊 Prueba 1 - zonedSchedule',
        'Debería aparecer en 10 segundos',
        scheduledTime,
        details,
        payload: 'medicamento_1001_Prueba_1',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      print('Método 1 (zonedSchedule) programado para: $scheduledTime');
      
    } catch (e) {
      print('Error en Método 1: $e');
    }
  }

  // Prueba notificaciones con intervalo de repeticion
  static Future<void> _probarRepeatInterval() async {
    try {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 20));
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'recordatorio_medicamento',
        'Recordatorios de Medicamentos',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        1002,
        '💊 Prueba 2 - Repeat Daily',
        'Debería aparecer en 20 segundos',
        scheduledTime,
        details,
        payload: 'medicamento_1002_Prueba_2',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      print('Método 2 (repeatInterval) programado para: $scheduledTime');
      
    } catch (e) {
      print('Error en Método 2: $e');
    }
  }

  // Muestra mensaje diagnostico sobre el estado de las notificaciones programadas
  static void _mostrarMensajeProgramacion() {
    print('');
    print('DIAGNÓSTICO DE NOTIFICACIONES PROGRAMADAS:');
    print('   1. Prueba 1 programada para 10 segundos');
    print('   2. Prueba 2 programada para 20 segundos'); 
    print('   3. Si no aparecen, necesitamos implementar WorkManager');
    print('   4. Las notificaciones inmediatas SÍ funcionan');
    print('');
  }

  // Metodo de prueba simple para notificaciones inmediatas
  static Future<void> probarNotificacionInmediata() async {
    await _mostrarNotificacionMedicamento(
      nombreMedicamento: 'Medicamento de Prueba Inmediata',
      idMedicamento: 8888,
      idMedicamentoReal: 8888,
    );
  }
}