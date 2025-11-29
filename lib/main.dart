import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padam_app/blocs/medicamento_bloc/medicamento_bloc.dart';
import 'package:padam_app/blocs/registro_toma_bloc/registro_toma_bloc.dart';
import 'package:padam_app/blocs/usuario_bloc/usuario_bloc.dart';
import 'package:padam_app/pages/login_page.dart';
import 'package:padam_app/repositories/medicamento_repository.dart';
import 'package:padam_app/repositories/registro_toma_repository.dart';
import 'package:padam_app/repositories/usuario_repository.dart';
import 'package:flutter/services.dart';
import 'package:padam_app/services/daily_reset_service.dart';
import 'package:padam_app/services/notification_service.dart';
import 'package:padam_app/services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  print('🚀 Iniciando aplicación PADAM...');

  // Inicializar notificaciones
  try {
    await NotificationService.initialize(
      onTap: (int idMedicamento, String nombreMedicamento) { // 👈 SOLO 2 PARÁMETROS
        print('🎯 Callback ejecutado: $idMedicamento - $nombreMedicamento');
        NavigationService.navigateToAccionNotificacionSimple(
          idMedicamento: idMedicamento,
          nombreMedicamento: nombreMedicamento,
          // imagenUrl: null, // 👈 TEMPORALMENTE SIN IMAGEN
        );
      }
    );
    
    // 👇 INICIALIZAR REINICIO DIARIO
    await DailyResetService.programarReinicioDiario();
    
    print('✅ Servicios inicializados correctamente');
  } catch (e) {
    print('❌ Error inicializando servicios: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('📱 Estado de la app cambiado: $state');
    
    if (state == AppLifecycleState.resumed) {
      // La app volvió al foreground - procesar notificaciones pendientes
      print('🔄 App en foreground - procesando notificaciones...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => UsuarioRepository()),
        RepositoryProvider(create: (context) => MedicamentoRepository()),
        RepositoryProvider(create: (context) => RegistroTomaRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => UsuarioBloc(
              usuarioRepository: context.read<UsuarioRepository>(),
            )..add(VerificarUsuarioExistente()),
          ),
          BlocProvider(
            create: (context) => MedicamentoBloc(
              medicamentoRepository: context.read<MedicamentoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => RegistroTomaBloc(
              registroTomaRepository: context.read<RegistroTomaRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'PADAM App',
          navigatorKey: NavigationService.navigatorKey,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Roboto',
          ),
          home: const LoginPage(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}