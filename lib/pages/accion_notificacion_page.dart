import 'dart:io';

import 'package:flutter/material.dart';
import 'package:padam_app/services/notification_service.dart';
import 'package:padam_app/services/registro_toma_service.dart';

// Pagina para registrar acciones sobre notificaciones de medicamentos
// 
// Funcionalidad:
// - Muestra interfaz para que el usuario registre si tomo el medicamento
// - Soporta tres acciones: Tomado, Posponer, Omitir
// - Muestra imagen del medicamento si esta disponible
// - Proporciona feedback inmediato al usuario
class AccionNotificacionPage extends StatelessWidget {
  final int idMedicamento;
  final String nombreMedicamento;
  final String? imagenUrl; // URL o path de la imagen del medicamento (opcional)

  const AccionNotificacionPage({
    super.key,
    required this.idMedicamento,
    required this.nombreMedicamento,
    this.imagenUrl, // Parametro opcional para mostrar imagen
  });

  @override
  Widget build(BuildContext context) {
    final registroService = RegistroTomaService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Toma'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Seccion de imagen del medicamento
            // Muestra la foto si existe, sino muestra un icono por defecto
            if (imagenUrl != null && imagenUrl!.isNotEmpty) ...[
              _buildFotoMedicamento(imagenUrl!),
              const SizedBox(height: 20),
            ] else ...[
              // Icono por defecto cuando no hay foto disponible
              Icon(
                Icons.medical_services,
                size: 80,
                color: Colors.blue[700],
              ),
              const SizedBox(height: 20),
            ],
            
            // Nombre del medicamento
            Text(
              '💊 $nombreMedicamento',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 10),
            const Text(
              '¿Qué acción deseas realizar?',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Boton para registrar que se tomo el medicamento
            _buildActionButton(
              icon: Icons.check_circle,
              title: '✅ Tomado',
              subtitle: 'Registrar como tomado',
              color: Colors.green,
              onTap: () {
                registroService.registrarTomaConfirmada(
                  idMedicamento: idMedicamento,
                  nombreMedicamento: nombreMedicamento,
                );
                _mostrarResultado(context, '✅ Toma registrada correctamente');
              },
            ),
            const SizedBox(height: 15),
            
            // Boton para posponer la toma por 10 minutos
            _buildActionButton(
              icon: Icons.schedule,
              title: '⏸ Posponer 10 min',
              subtitle: 'Recordarme más tarde',
              color: Colors.orange,
              onTap: () async {
                // Registra la postergación en BD (tu código existente)
                await registroService.registrarPostergacion(
                  idMedicamento: idMedicamento,
                  nombreMedicamento: nombreMedicamento,
                );
                // Cancela la notificación original (opcional, pero recomendado)
                await NotificationService.cancelarRecordatorio(idMedicamento);
                // Reprograma la notificación para 10 minutos después
                final ahora = DateTime.now();
                final nuevaHora = ahora.add(const Duration(minutes: 10));
                await NotificationService.programarRecordatorioMedicamento(
                  nombreMedicamento: nombreMedicamento,
                  hora: nuevaHora.hour,
                  minuto: nuevaHora.minute,
                  diasSemana: [],  // Vacío para una sola notificación (no semanal)
                  idMedicamento: idMedicamento,
                  imagenUrl: imagenUrl,
                );
                // Muestra resultado y cierra
                _mostrarResultado(context, '⏸ Recordatorio pospuesto 10 minutos');
              },
            ),
            const SizedBox(height: 15),
            
            // Boton para omitir la toma actual
            _buildActionButton(
              icon: Icons.cancel,
              title: '❌ Omitir',
              subtitle: 'No tomar esta dosis',
              color: Colors.red,
              onTap: () {
                registroService.registrarOmision(
                  idMedicamento: idMedicamento,
                  nombreMedicamento: nombreMedicamento,
                );
                _mostrarResultado(context, '❌ Toma omitida');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Construye el widget para mostrar la foto del medicamento
  // Maneja diferentes casos: archivo existe, ruta alternativa, error
  Widget _buildFotoMedicamento(String imagenUrl) {
    print('Verificando imagen: $imagenUrl');
    
    try {
      final file = File(imagenUrl);
      final fileExists = file.existsSync();
      
      print('Archivo existe: $fileExists');
      print('Tamaño del archivo: ${fileExists ? file.lengthSync() : 0} bytes');
      
      if (!fileExists) {
        // Intentar con ruta alternativa para manejar diferencias en paths
        final rutaAlternativa = imagenUrl.replaceFirst('com.example.padam/app', 'com.example.padam_app');
        final fileAlt = File(rutaAlternativa);
        final fileAltExists = fileAlt.existsSync();
        
        print('Probando ruta alternativa: $rutaAlternativa');
        print('Archivo alternativo existe: $fileAltExists');
        
        if (fileAltExists) {
          return _buildImagenWidget(fileAlt);
        }
        
        return _buildPlaceholder();
      }
      
      return _buildImagenWidget(file);
      
    } catch (e) {
      print('Error verificando imagen: $e');
      return _buildPlaceholder();
    }
  }

  // Construye el widget de imagen con estilo y manejo de errores
  Widget _buildImagenWidget(File file) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error cargando imagen: $error');
            return _buildPlaceholder();
          },
        ),
      ),
    );
  }

  // Widget placeholder cuando no hay imagen disponible
  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.grey[200],
      ),
      child: const Icon(
        Icons.photo,
        size: 30,
        color: Colors.grey,
      ),
    );
  }

  // Construye un boton de accion estilizado
  // Parametros:
  //   - icon: Icono a mostrar
  //   - title: Texto principal del boton
  //   - subtitle: Texto secundario descriptivo
  //   - color: Color temático del boton
  //   - onTap: Funcion a ejecutar al presionar
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 32, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  // Muestra un mensaje de resultado y cierra la pantalla automaticamente
  // Parametros:
  //   - context: Contexto de navegacion
  //   - mensaje: Mensaje a mostrar en el SnackBar
  void _mostrarResultado(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Cierra la pantalla automaticamente despues de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }
}