import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/mis_vehiculos_screen.dart';
import 'screens/reportar_emergencia_screen.dart';
import 'screens/mis_incidentes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AutoFixApp());
}

class AutoFixApp extends StatelessWidget {
  const AutoFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoFix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE63946),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/registro': (context) => const RegistroScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => DashboardScreen(token: token),
          );
        }
        if (settings.name == '/mis-vehiculos') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => MisVehiculosScreen(token: token),
          );
        }
        if (settings.name == '/reportar-emergencia') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ReportarEmergenciaScreen(token: token),
          );
        }
        if (settings.name == '/mis-incidentes') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => MisIncidentesScreen(token: token),
          );
        }
        return null;
      },
    );
  }
}