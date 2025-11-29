import 'package:flutter/material.dart';
import 'package:padam_app/widgets/accion_notification_bottomsheet.dart';

// Servicio para gestionar la navegacion global de la aplicacion
// 
// Funcionalidad:
// - Proporciona una clave de navegacion global
// - Maneja navegacion desde cualquier parte de la aplicacion
// - Especializado en mostrar el BottomSheet de acciones de notificacion
class NavigationService {
  // Clave global para el Navigator, permite acceso al contexto de navegacion desde cualquier lugar
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Obtiene el contexto actual de navegacion
  static BuildContext? get context => navigatorKey.currentContext;
  
  // Navega hacia el BottomSheet de accion de notificacion
  // Parametros:
  //   - idMedicamento: ID del medicamento relacionado
  //   - nombreMedicamento: Nombre del medicamento a mostrar
  //   - imagenUrl: Ruta de la imagen del medicamento (opcional)
  static void navigateToAccionNotificacionSimple({
    required int idMedicamento,
    required String nombreMedicamento,
    String? imagenUrl, // Parametro opcional para mostrar imagen
  }) {
    print('Mostrando BottomSheet para: $nombreMedicamento');
    
    // Usar addPostFrameCallback para asegurar que el contexto este disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentContext = navigatorKey.currentState?.context;
      if (currentContext != null) {
        AccionNotificacionBottomSheet.show(
          context: currentContext,
          idMedicamento: idMedicamento,
          nombreMedicamento: nombreMedicamento,
          imagenUrl: imagenUrl, // Pasar null si no hay imagen
        );
        print('BottomSheet mostrado exitosamente');
      }
    });
  }
}