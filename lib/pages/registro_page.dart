import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padam_app/blocs/usuario_bloc/usuario_bloc.dart';
import 'package:padam_app/models/usuario.dart';
import 'package:padam_app/pages/home_page.dart';

// Pagina para registro de nuevos usuarios en el sistema
// 
// Funcionalidad:
// - Formulario completo de registro de perfil de usuario
// - Validaciones de datos personales y credenciales
// - Integracion con BLoC para gestion de usuarios
// - Navegacion automatica a Home tras registro exitoso
class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _fechaNacController = TextEditingController();
  final _pinController = TextEditingController();
  String _generoSeleccionado = 'Masculino';
  DateTime _fechaNacimiento = DateTime.now().subtract(const Duration(days: 365 * 70));
  final _nombreUsuarioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Crear tu Perfil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Regresa a la pagina de login
          },
        ),
      ),
      body: BlocListener<UsuarioBloc, UsuarioState>(
        listener: (context, state) {
          // Manejar respuesta del registro
          if (state is UsuarioRegistrado) {
            // Navegar a la pantalla principal tras registro exitoso
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(usuario: state.usuario)),
            );
          } else if (state is UsuarioError) {
            // Mostrar errores durante el registro
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Campo de nombre completo
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Completo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    style: const TextStyle(fontSize: 18),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo de nombre de usuario (para login)
                  TextFormField(
                    controller: _nombreUsuarioController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de usuario (para ingresar a la app)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                      hintText: 'Ej: maria.gonzalez',
                    ),
                    style: const TextStyle(fontSize: 18),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un nombre de usuario';
                      }
                      if (value.length < 3) {
                        return 'El nombre de usuario debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Campo de fecha de nacimiento
                  TextFormField(
                    controller: _fechaNacController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Nacimiento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    style: const TextStyle(fontSize: 18),
                    readOnly: true, // Evita edicion manual
                    onTap: () => _seleccionarFecha(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona tu fecha de nacimiento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Selector de genero
                  DropdownButtonFormField<String>(
                    initialValue: _generoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Género',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    dropdownColor: Colors.white,
                    items: ['Masculino', 'Femenino']
                        .map((genero) => DropdownMenuItem(
                              value: genero,
                              child: Text(
                                genero,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _generoSeleccionado = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Campo de PIN de seguridad
                  TextFormField(
                    controller: _pinController,
                    decoration: const InputDecoration(
                      labelText: 'PIN de 4 dígitos',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    style: const TextStyle(fontSize: 18, letterSpacing: 8),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length != 4) {
                        return 'El PIN debe tener 4 dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  // Boton principal de registro
                  BlocBuilder<UsuarioBloc, UsuarioState>(
                    builder: (context, state) {
                      if (state is UsuarioLoading) {
                        return const CircularProgressIndicator();
                      }
                      
                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _registrarUsuario(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        child: const Text('Comenzar a Usar la App'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Abre el selector de fecha nativo
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Minimo 18 años
      helpText: 'Selecciona tu fecha de nacimiento',
      initialEntryMode: DatePickerEntryMode.calendar,
    );
    
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
        _fechaNacController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
      print('Fecha seleccionada: $_fechaNacimiento');
    } else {
      print('No se seleccionó fecha o es la misma');
    }
  }

  // Valida y registra el nuevo usuario en el sistema
  void _registrarUsuario(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Validaciones adicionales de fecha de nacimiento
      final ahora = DateTime.now();
      final edadMinima = ahora.subtract(const Duration(days: 365 * 18)); // Minimo 18 años
      final edadMaxima = ahora.subtract(const Duration(days: 365 * 120)); // Maximo 120 años
      
      if (_fechaNacimiento.isAfter(edadMinima)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes ser mayor de 18 años')),
        );
        return;
      }
      
      if (_fechaNacimiento.isBefore(edadMaxima)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor verifica tu fecha de nacimiento')),
        );
        return;
      }
      
      // Crear objeto Usuario con los datos capturados
      final usuario = Usuario(
        nombreUsu: _nombreController.text.trim(),
        nombreUsuario: _nombreUsuarioController.text.trim().toLowerCase(), // Convertir a minusculas
        fechaNac: _fechaNacimiento,
        genero: _generoSeleccionado,
        pin: _pinController.text,
        fechaRegistro: DateTime.now(),
        rut: null, // No es parte del diccionario de datos
        direccion: null, // Opcional por ahora
      );
      
      print('Registrando usuario: ${usuario.nombreUsu}');
      print('Fecha de nacimiento: ${usuario.fechaNac}');
      
      // Disparar evento de registro
      context.read<UsuarioBloc>().add(RegistrarUsuario(usuario));
    }
  }

  @override
  void dispose() {
    // Limpiar controladores para evitar memory leaks
    _nombreController.dispose();
    _nombreUsuarioController.dispose();
    _fechaNacController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}