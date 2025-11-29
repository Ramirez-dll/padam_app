import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padam_app/blocs/usuario_bloc/usuario_bloc.dart';
import 'package:padam_app/pages/home_page.dart';
import 'package:padam_app/pages/registro_page.dart';

// Pagina de autenticacion y primer acceso a la aplicacion
// 
// Funcionalidad:
// - Verifica si existe un usuario registrado en el dispositivo
// - Proporciona formulario de login con usuario y PIN
// - Redirige automaticamente si hay sesion activa
// - Ofrece opcion para crear nuevo perfil
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usuarioController = TextEditingController();
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _verificacionCompletada = false;

  @override
  void initState() {
    super.initState();
    // Verificar existencia de usuario despues de que la UI este lista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsuarioBloc>().add(VerificarUsuarioExistente());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<UsuarioBloc, UsuarioState>(
        listener: (context, state) {
          print('Estado del BLoC: $state');
          
          // Manejar navegacion automatica a Home si hay sesion activa
          if (state is UsuarioEnSesion || state is PinCorrecto) {
            final usuario = state is UsuarioEnSesion 
                ? state.usuario 
                : (state as PinCorrecto).usuario;
            
            print('Navegando a Home');
            // Navegar despues del frame actual para evitar conflictos
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage(usuario: usuario)),
                (route) => false, // Limpiar completamente el stack de navegacion
              );
            });
          } else if (state is UsuarioNoExiste && !_verificacionCompletada) {
            // Mostrar formulario de login cuando no hay usuarios registrados
            print('No hay usuarios registrados, mostrando formulario de login');
            setState(() {
              _verificacionCompletada = true;
            });
          } else if (state is UsuarioError) {
            // Mostrar errores de autenticacion
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono principal de la aplicacion
              Icon(
                Icons.medical_services,
                size: 80,
                color: Colors.blue[700],
              ),
              const SizedBox(height: 20),
              
              // Titulo de la aplicacion
              const Text(
                'PADAM App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              
              // Subtitulo descriptivo
              const Text(
                'Gestión de Medicamentos',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              
              // Campo de nombre de usuario
              TextField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                style: const TextStyle(fontSize: 18),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),
              
              // Campo de PIN de seguridad
              TextField(
                controller: _pinController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  labelText: 'PIN de 4 dígitos',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                style: const TextStyle(fontSize: 20, letterSpacing: 8), // Espaciado para mejor legibilidad
                keyboardType: TextInputType.number,
                maxLength: 4, // Limitar a 4 digitos exactos
                obscureText: true, // Ocultar texto por seguridad
                textAlign: TextAlign.center, // Centrado para mejor apariencia
              ),
              const SizedBox(height: 30),
              
              // Boton principal de ingreso
              BlocBuilder<UsuarioBloc, UsuarioState>(
                builder: (context, state) {
                  if (state is UsuarioLoading) {
                    return const CircularProgressIndicator();
                  }
                  
                  return ElevatedButton(
                    onPressed: () => _verificarLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Ingresar'),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Opcion alternativa para crear nuevo perfil
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistroPage()),
                  );
                },
                child: const Text(
                  'Crear nuevo perfil',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              // Mensaje informativo cuando no hay usuarios registrados
              BlocBuilder<UsuarioBloc, UsuarioState>(
                builder: (context, state) {
                  if (state is UsuarioNoExiste && _verificacionCompletada) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'No hay usuarios registrados. Crea un nuevo perfil.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Valida y procesa el intento de login
  void _verificarLogin(BuildContext context) {
    final usuario = _usuarioController.text.trim();
    final pin = _pinController.text;
    
    // Validaciones basicas de los campos
    if (usuario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu nombre de usuario')),
      );
      return;
    }
    
    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El PIN debe tener 4 dígitos')),
      );
      return;
    }
    
    // Disparar evento de verificacion de credenciales
    context.read<UsuarioBloc>().add(VerificarLogin(usuario, pin));
  }

  @override
  void dispose() {
    // Limpiar recursos para evitar memory leaks
    _usuarioController.dispose();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}