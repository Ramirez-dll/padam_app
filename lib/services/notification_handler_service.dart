import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:padam_app/services/registro_toma_service.dart';

// Servicio para manejar las respuestas a las notificaciones push
// 
// Responsabilidades:
// - Procesa los taps y acciones en notificaciones
// - Delega a RegistroTomaService para registrar las tomas
// - Proporciona feedback al usuario despues de las acciones
class NotificationHandlerService {
  static final RegistroTomaService _registroService = RegistroTomaService();

  // Maneja la respuesta del usuario a una notificacion
  // Se llama cuando el usuario hace tap en la notificacion o en sus acciones
  // Parametros:
  //   - response: Objeto con la accion y payload de la notificacion
  static void manejarRespuesta(NotificationResponse response) {
    print('NotificationHandlerService - Manejar respuesta:');
    print('   - Acción: ${response.actionId}');
    print('   - Payload: ${response.payload}');
    
    final accion = response.actionId ?? 'tap'; // 'tap' si solo se toco la notificacion
    final payload = response.payload;
    
    // Procesar notificaciones de medicamentos
    if (payload != null && payload.startsWith('medicamento_')) {
      _procesarAccionMedicamento(accion, payload);
    } else {
      print('Notificación general tocada');
    }
  }

  // Procesa acciones especificas para notificaciones de medicamentos
  // Parametros:
  //   - accion: Tipo de accion (tomado, posponer, omitido, tap)
  //   - payload: Payload de la notificacion que contiene el ID del medicamento
  static void _procesarAccionMedicamento(String accion, String payload) {
    // Extraer ID del medicamento del payload
    final idStr = payload.replaceFirst('medicamento_', '');
    final idMedicamento = int.tryParse(idStr);
    
    if (idMedicamento == null) {
      print('ID de medicamento inválido: $idStr');
      return;
    }
    
    print('Procesando acción: $accion para medicamento $idMedicamento');
    
    // Delegar a metodo especifico segun la accion
    switch (accion) {
      case 'tomado':
        _procesarTomado(idMedicamento);
        break;
      case 'posponer':
        _procesarPosponer(idMedicamento);
        break;
      case 'omitido':
        _procesarOmitido(idMedicamento);
        break;
      case 'tap':
        _procesarTap(idMedicamento);
        break;
      default:
        print('Acción no reconocida: $accion');
    }
  }

  // Procesa la accion "tomado" - registra que se tomo el medicamento
  static void _procesarTomado(int idMedicamento) {
    print('Procesando TOMADO para medicamento $idMedicamento');
    
    _registroService.registrarTomaConfirmada(
      idMedicamento: idMedicamento,
      nombreMedicamento: 'Medicamento $idMedicamento', // Nombre temporal
    );
    
    _mostrarConfirmacion('Toma registrada');
  }

  // Procesa la accion "posponer" - registra postergacion por 10 minutos
  static void _procesarPosponer(int idMedicamento) {
    print('Procesando POSPONER para medicamento $idMedicamento');
    
    _registroService.registrarPostergacion(
      idMedicamento: idMedicamento,
      nombreMedicamento: 'Medicamento $idMedicamento', // Nombre temporal
    );
    
    _mostrarConfirmacion('Recordatorio pospuesto 10min');
    
    // TODO: Aquí se podria reprogramar la notificacion para 10 minutos despues
  }

  // Procesa la accion "omitido" - registra que se omitio la toma
  static void _procesarOmitido(int idMedicamento) {
    print('Procesando OMITIDO para medicamento $idMedicamento');
    
    _registroService.registrarOmision(
      idMedicamento: idMedicamento,
      nombreMedicamento: 'Medicamento $idMedicamento', // Nombre temporal
    );
    
    _mostrarConfirmacion('Toma omitida');
  }

  // Procesa el "tap" en la notificacion - abre la app para mas detalles
  static void _procesarTap(int idMedicamento) {
    print('Notificación tocada para medicamento $idMedicamento');
    // TODO: Podriamos abrir la app en la pantalla de medicamentos
    _mostrarConfirmacion('Abriendo detalles...');
  }

  // Muestra una confirmacion al usuario (por implementar)
  // Parametros:
  //   - mensaje: Mensaje de confirmacion a mostrar
  static Future<void> _mostrarConfirmacion(String mensaje) async {
    // TODO: Mostrar notificación de confirmación
    // Esto podria ser un SnackBar, un Toast o una notificacion secundaria
    print('Confirmación: $mensaje');
  }
}