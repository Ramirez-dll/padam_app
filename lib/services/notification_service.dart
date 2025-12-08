import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:padam_app/repositories/medicamento_repository.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:padam_app/models/medicamento.dart';

// Función top-level para manejar respuestas en background (requerido por flutter_local_notifications)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('Notificación tocada en background: ${notificationResponse.payload}');
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _inicializado = false;

  static Function(int, String)? onNotificacionTap;

  // Mapa para almacenar IDs originales -> IDs mapeados (para cancelaciones)
  static final Map<int, int> _idMap = {};

  static Future<void> initialize({Function(int, String)? onTap}) async {
    if (_inicializado) return;
    
    onNotificacionTap = onTap;
    
    print('Inicializando NotificationService...');
    
    try {
      tz.initializeTimeZones();
      
      // Solicitar permisos necesarios para notificaciones programadas
      await _solicitarPermisos();
      
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
      
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      await _crearCanalNotificaciones();
      
      _inicializado = true;
      print('NotificationService inicializado correctamente');
      
    } catch (e) {
      print('Error en NotificationService: $e');
    }
  }

  // Solicitar permisos para scheduling exacto (Android 12+)
  static Future<void> _solicitarPermisos() async {
    if (await Permission.scheduleExactAlarm.isGranted) {
      print('✅ Permiso SCHEDULE_EXACT_ALARM ya concedido');
    } else {
      final status = await Permission.scheduleExactAlarm.request();
      if (status.isGranted) {
        print('✅ Permiso SCHEDULE_EXACT_ALARM concedido');
      } else {
        print('❌ Permiso SCHEDULE_EXACT_ALARM denegado. Las notificaciones programadas no funcionarán.');
      }
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    print('Notificación tocada en foreground:');
    print('   - Payload: ${response.payload}');
    _procesarPayload(response.payload);
  }

  static void _procesarPayload(String? payload) {
    if (payload != null && payload.startsWith('medicamento_')) {
      print('Procesando payload: $payload');
      
      final partes = payload.split('_');
      if (partes.length >= 3) {
        final idMedicamento = int.tryParse(partes[1]);
        final nombreCompleto = partes.sublist(2).join('_');
        
        final partesNombre = nombreCompleto.split('|');
        final nombreMedicamento = partesNombre.first.replaceAll('_', ' ');
        String? imagenUrl;
        
        if (partesNombre.length > 1) {
          imagenUrl = partesNombre[1].replaceAll('_', '/');
          imagenUrl = imagenUrl.replaceFirst('com.example.padam/app', 'com.example.padam_app');
        }
        
        if (idMedicamento != null) {
          print('Medicamento: $nombreMedicamento');
          print('Imagen: $imagenUrl');
          
          if (onNotificacionTap != null) {
            onNotificacionTap!(idMedicamento, nombreMedicamento);
          }
          
          _reprogramarSiguienteNotificacion(idMedicamento, nombreMedicamento, partesNombre.length > 1 ? partesNombre[1] : null);
        }
      }
    }
  }

  static Future<void> _reprogramarSiguienteNotificacion(int idMedicamento, String nombreMedicamento, String? imagenUrl) async {
    final medicamento = await _obtenerMedicamentoPorId(idMedicamento);
    if (medicamento != null) {
      await programarRecordatorioMedicamento(
        nombreMedicamento: medicamento.nombreMed,  // Ajusta según propiedades reales
        hora: medicamento.horarioMed.hour,
        minuto: medicamento.horarioMed.minute,
        diasSemana: medicamento.diasSemana.split(',').map((d) => d.trim()).toList(),  // Asume que es una cadena separada por comas
        idMedicamento: idMedicamento,
        imagenUrl: imagenUrl,
      );
      print('✅ Reprogramado para el próximo día válido');
    } else {
      print('❌ No se pudo reprogramar: medicamento no encontrado');
    }
  }

  static Future<Medicamento?> _obtenerMedicamentoPorId(int id) async {
    final repo = MedicamentoRepository();
    return await repo.obtenerMedicamentoPorId(id);  // Cambiado aquí
  }

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

  // Función para mapear ID grande a uno pequeño (int32 válido)
  static int _mapId(int originalId) {
    final mappedId = originalId % 1000000;
    _idMap[originalId] = mappedId;
    print('ID original: $originalId -> ID mapeado: $mappedId');
    return mappedId;
  }

  static Future<void> programarRecordatorioMedicamento({
    required String nombreMedicamento,
    required int hora,
    required int minuto,
    required List<String> diasSemana,
    required int idMedicamento,
    String? imagenUrl,
  }) async {
    print('Programando recordatorio para: $nombreMedicamento');
    print('Horario: $hora:$minuto');
    print('Días: ${diasSemana.join(', ')}');
    
    try {
      final scheduledTime = _calcularProximaFecha(hora, minuto, diasSemana);
      if (scheduledTime == null) {
        print('No se pudo calcular una fecha válida para los días especificados.');
        return;
      }
      
      // Define mappedId aquí para usarlo en todo el método
      final mappedId = _mapId(idMedicamento);
      
      final nombreCodificado = nombreMedicamento.replaceAll(' ', '_');
      final imagenCodificada = imagenUrl?.replaceAll('/', '_') ?? '';
      final payload = imagenCodificada.isNotEmpty 
          ? 'medicamento_${idMedicamento}_$nombreCodificado|$imagenCodificada'
          : 'medicamento_${idMedicamento}_$nombreCodificado';
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'recordatorio_medicamento',
        'Recordatorios de Medicamentos',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      // Flag para emulador (cambia a false para producción en dispositivo real)
      const bool isEmulator = true;  // true = usa Timer (hack); false = usa zonedSchedule
      
      if (isEmulator) {
        // Hack para emulador: usa Timer
        final now = tz.TZDateTime.now(tz.local);
        final delay = scheduledTime.difference(now).inSeconds;
        if (delay > 0) {
          Timer(Duration(seconds: delay), () async {
            print('⏰ Hack Timer activado: mostrando notificación programada en emulador');
            await _mostrarNotificacionMedicamento(
              nombreMedicamento: nombreMedicamento,
              idMedicamento: mappedId,
              idMedicamentoReal: idMedicamento,
              imagenUrl: imagenUrl,
            );
            // Reprogramar para el próximo día (simular repetición semanal)
            _reprogramarSiguienteNotificacion(idMedicamento, nombreMedicamento, imagenUrl);
          });
          print('✅ Timer programado para: $scheduledTime (delay: $delay segundos)');
        } else {
          print('⚠️ Hora ya pasó, no se programa');
        }
      } else {
        // Para producción: usa zonedSchedule
        await _notifications.zonedSchedule(
          mappedId,
          '💊 Hora de: $nombreMedicamento',
          'Toca para registrar la toma',
          scheduledTime,
          details,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        print('✅ Notificación programada con zonedSchedule para: $scheduledTime');
      }
      
      print('✅ Notificación programada exitosamente para: $scheduledTime (ID mapeado: $mappedId)');
    } catch (e) {
      print('❌ Error programando notificación: $e');
    }
  }

  static tz.TZDateTime? _calcularProximaFecha(int hora, int minuto, List<String> diasSemana) {
    final now = tz.TZDateTime.now(tz.local);
    print('Hora actual: $now');
    
    final Map<String, int> diasMap = {
      'lunes': 1, 'martes': 2, 'miercoles': 3, 'jueves': 4, 'viernes': 5, 'sabado': 6, 'domingo': 7,
      'l': 1, 'm': 2, 'x': 3, 'j': 4, 'v': 5, 's': 6, 'd': 7,
      'lun': 1, 'mar': 2, 'mie': 3, 'jue': 4, 'vie': 5, 'sab': 6, 'dom': 7,
    };
    
    tz.TZDateTime? fechaMasCercana;
    
    for (String dia in diasSemana) {
      final diaLower = dia.toLowerCase();
      final diaInt = diasMap[diaLower];
      print('Procesando día: $dia -> $diaLower -> $diaInt');
      
      if (diaInt == null) continue;
      
      int diasHasta = (diaInt - now.weekday + 7) % 7;
      if (diasHasta == 0 && (now.hour > hora || (now.hour == hora && now.minute >= minuto))) {
        diasHasta = 7;  // Si hoy es el día pero la hora ya pasó, ir al próximo
      }
      
      final fechaBase = now.add(Duration(days: diasHasta));
      final fechaCandidata = tz.TZDateTime(tz.local, fechaBase.year, fechaBase.month, fechaBase.day, hora, minuto);
      
      print('Fecha candidata para $dia: $fechaCandidata');
      
      // Elegir la fecha más cercana futura
      if (fechaCandidata.isAfter(now) && (fechaMasCercana == null || fechaCandidata.isBefore(fechaMasCercana))) {
        fechaMasCercana = fechaCandidata;
      }
    }
    
    print('Fecha más cercana seleccionada: $fechaMasCercana');
    return fechaMasCercana;
  }

  static Future<void> cancelarRecordatorio(int idMedicamento) async {
    final mappedId = _idMap[idMedicamento] ?? _mapId(idMedicamento);
    await _notifications.cancel(mappedId);
    print('Notificación cancelada: ID original $idMedicamento -> mapeado $mappedId');
  }

  static Future<void> probarNotificacionInmediata() async {
    await _mostrarNotificacionMedicamento(
      nombreMedicamento: 'Medicamento de Prueba Inmediata',
      idMedicamento: 8888,
      idMedicamentoReal: 8888,
    );
  }

  // Método de prueba agresivo: programa repetición cada 1 minuto (para verificar scheduling en emulador)
  static Future<void> probarNotificacionProgramada() async {
    print('Probando notificación con repeatInterval (cada 1 minuto)...');
    
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'recordatorio_medicamento',
        'Recordatorios de Medicamentos',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      // Repite cada 1 minuto (para prueba en emulador)
      await _notifications.periodicallyShow(
        9999,
        '💊 Prueba Repeat',
        'Aparece cada 1 minuto',
        RepeatInterval.everyMinute,
        details,
        payload: 'medicamento_9999_Prueba_Repeat',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,  // Parámetro obligatorio agregado
      );
      
      print('✅ Prueba con repeatInterval programada');
    } catch (e) {
      print('❌ Error en prueba repeat: $e');
    }
  }

  static Future<void> _mostrarNotificacionMedicamento({
    required String nombreMedicamento,
    required int idMedicamento,
    required int idMedicamentoReal,
    String? imagenUrl,
  }) async {
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

    final payload = imagenCodificada.isNotEmpty 
        ? 'medicamento_${idMedicamentoReal}_$nombreCodificado|$imagenCodificada'
        : 'medicamento_${idMedicamentoReal}_$nombreCodificado';

    await _notifications.show(
      idMedicamento,
      '💊 Hora de: $nombreMedicamento',
      'Toca para registrar la toma',
      details,
      payload: payload,
    );
    
    print('Notificación INMEDIATA mostrada: $nombreMedicamento');
  }
}