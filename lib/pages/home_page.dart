import 'package:flutter/material.dart';
import 'package:padam_app/models/usuario.dart';
import 'package:padam_app/pages/lista_medicamentos_page.dart';
import 'package:padam_app/services/notification_service.dart';
import 'package:padam_app/services/session_service.dart';
import 'package:padam_app/pages/login_page.dart';

// Pagina principal de la aplicacion - Dashboard del usuario
// 
// Funcionalidad:
// - Pantalla de inicio despues del login
// - Menu principal con acceso a todas las funcionalidades
// - Informacion personalizada con nombre de usuario
// - Navegacion centralizada a modulos de la app
class HomePage extends StatelessWidget {
  final Usuario usuario;
  
  const HomePage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    final months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    
    final dayOfWeek = days[now.weekday - 1];
    final day = now.day;
    final month = months[now.month - 1];
    final year = now.year;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PADAM App',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de bienvenida con informacion personalizada
              _buildWelcomeHeader(dayOfWeek, day, month, year),
              const SizedBox(height: 30),
              
              // Grid de funcionalidades principales
              // Uso de Expanded para evitar problemas de overflow
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0, // Tarjetas cuadradas
                  children: [
                    // Tarjeta de Medicamentos - Funcionalidad principal
                    _buildFeatureCard(
                      icon: Icons.medication_liquid,
                      title: 'Medicamentos',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListaMedicamentosPage(idUsuario: usuario.idUsuario!),
                          ),
                        );
                      },
                    ),
                    // Tarjeta de Estado de Animo - En desarrollo
                    _buildFeatureCard(
                      icon: Icons.emoji_emotions,
                      title: 'Estado de Ánimo',
                      color: Colors.orange,
                      onTap: () {
                        _showComingSoon(context, 'Estado de Ánimo');
                      },
                    ),
                    // Tarjeta de Actividades - En desarrollo
                    _buildFeatureCard(
                      icon: Icons.calendar_today,
                      title: 'Actividades',
                      color: Colors.green,
                      onTap: () {
                        _showComingSoon(context, 'Actividades Diarias');
                      },
                    ),
                    // Tarjeta de Resumen - En desarrollo
                    _buildFeatureCard(
                      icon: Icons.bar_chart,
                      title: 'Mi Resumen',
                      color: Colors.purple,
                      onTap: () {
                        _showComingSoon(context, 'Mi Resumen');
                      },
                    ),
                    // Tarjeta de Configuracion
                    _buildFeatureCard(
                      icon: Icons.settings,
                      title: 'Configuración',
                      color: Colors.grey,
                      onTap: () {
                        _showConfiguracion(context);
                      },
                    ),
                    // Tarjeta de prueba de notificaciones - Solo para desarrollo
                    _buildFeatureCard(
                      icon: Icons.notifications,
                      title: 'Probar Notificación',
                      color: Colors.blue,
                      onTap: () {
                        print('Probando notificación...');
                        NotificationService.probarNotificacionInmediata();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construye el header de bienvenida con fecha y saludo personalizado
  Widget _buildWelcomeHeader(String dayOfWeek, int day, String month, int year) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Hola, ${usuario.nombreUsu.split(' ')[0]}!', // Usa solo el primer nombre
          style: const TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$dayOfWeek, $day de $month de $year', // Fecha formateada en español
          style: TextStyle(
            fontSize: 22,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '¿Qué te gustaría hacer hoy?', // Invitacion a la accion
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Construye una tarjeta de funcionalidad del dashboard
  // Parametros:
  //   - icon: Icono representativo de la funcionalidad
  //   - title: Titulo de la funcionalidad
  //   - color: Color tematico de la tarjeta
  //   - onTap: Accion a ejecutar al presionar
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono circular con color de fondo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              // Titulo de la funcionalidad
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Muestra un dialogo informando que una funcionalidad esta en desarrollo
  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Próximamente',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'La funcionalidad de "$feature" estará disponible muy pronto.',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  // Muestra el menu de configuracion en un bottom sheet
  void _showConfiguracion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Configuración',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Opcion de perfil de usuario
            _buildConfigOption(
              icon: Icons.person,
              title: 'Mi Perfil',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Mi Perfil');
              },
            ),
            // Opcion de configuracion de notificaciones
            _buildConfigOption(
              icon: Icons.notifications,
              title: 'Notificaciones',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Notificaciones');
              },
            ),
            // Opcion de accesibilidad (tamaño de texto)
            _buildConfigOption(
              icon: Icons.visibility,
              title: 'Tamaño de Texto',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Tamaño de Texto');
              },
            ),
            // Opcion de cerrar sesion (destacada en rojo)
            _buildConfigOption(
              icon: Icons.logout,
              title: 'Cerrar Sesión',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _confirmarCerrarSesion(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Construye una opcion del menu de configuracion
  Widget _buildConfigOption({
    required IconData icon,
    required String title,
    Color color = Colors.black87,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28, color: color),
      title: Text(
        title,
        style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Muestra dialogo de confirmacion para cerrar sesion
  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          // Boton de cancelar
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(fontSize: 20),
            ),
          ),
          // Boton de confirmar cerrar sesion
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Cerrar sesion en el servicio
              await SessionService.cerrarSesion();
              // Navegar al login y limpiar stack de navegacion
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: Text(
              'Cerrar Sesión',
              style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}