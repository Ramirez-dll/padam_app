import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:padam_app/services/registro_toma_service.dart';

class AccionNotificacionBottomSheet extends StatelessWidget {
  final int idMedicamento;
  final String nombreMedicamento;
  final String? imagenUrl;

  const AccionNotificacionBottomSheet({
    super.key,
    required this.idMedicamento,
    required this.nombreMedicamento,
    this.imagenUrl,
  });

  static void show({
    required BuildContext context,
    required int idMedicamento,
    required String nombreMedicamento,
    String? imagenUrl,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AccionNotificacionBottomSheet(
        idMedicamento: idMedicamento,
        nombreMedicamento: nombreMedicamento,
        imagenUrl: imagenUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final registroService = RegistroTomaService();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Registrar Toma',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  // 👇 AL CERRAR SIN ACCIÓN, REGISTRAR COMO OMITIDO
                  registroService.registrarOmision(
                    idMedicamento: idMedicamento,
                    nombreMedicamento: nombreMedicamento,
                  );
                  Navigator.of(context).pop();
                  _mostrarResultado(context, '⏭️ Toma omitida');
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Foto del medicamento (si existe) - VERSIÓN SIMPLIFICADA
          if (imagenUrl != null && imagenUrl!.isNotEmpty) ...[
            _buildFotoMedicamento(imagenUrl!),
            const SizedBox(height: 20),
          ] else ...[
            // Icono por defecto si no hay foto
            Icon(
              Icons.medical_services,
              size: 60,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 10),
          ],
          
          // Contenido
          Text(
            '💊 $nombreMedicamento',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 10),
          const Text(
            '¿Has tomado tu medicamento?',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // 👇 SOLO DOS BOTONES: TOMADO Y POSPONER
          _buildActionButton(
            context: context,
            icon: Icons.check_circle,
            title: '✅ Sí, lo tomé',
            subtitle: 'Registrar como tomado',
            color: Colors.green,
            onTap: () {
              registroService.registrarTomaConfirmada(
                idMedicamento: idMedicamento,
                nombreMedicamento: nombreMedicamento,
              );
              Navigator.of(context).pop();
              _mostrarResultado(context, '✅ Toma registrada');
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildActionButton(
            context: context,
            icon: Icons.schedule,
            title: '⏸ Recordármelo luego',
            subtitle: 'Posponer 10 minutos',
            color: Colors.orange,
            onTap: () {
              registroService.registrarPostergacion(
                idMedicamento: idMedicamento,
                nombreMedicamento: nombreMedicamento,
              );
              Navigator.of(context).pop();
              _mostrarResultado(context, '⏸ Recordatorio pospuesto');
            },
          ),
          
          const SizedBox(height: 20),
          
          // 👇 TEXTO INFORMATIVO SOBRE OMISIÓN AUTOMÁTICA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Si cierras esta ventana, se registrará como omitido automáticamente',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFotoMedicamento(String imagenUrl) {
    // 👇 VERIFICAR QUE EL ARCHIVO EXISTE ANTES DE MOSTRARLO
    final file = File(imagenUrl);
    final fileExists = file.existsSync();
    
    print('📁 Verificando imagen: $imagenUrl');
    print('📄 Archivo existe: $fileExists');
    
    if (!fileExists) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
    
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error cargando imagen: $error');
            return Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.photo,
                size: 30,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 28, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  void _mostrarResultado(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}