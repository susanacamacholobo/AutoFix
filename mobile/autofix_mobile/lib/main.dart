import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/roles_screen.dart';
import 'screens/permisos_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/registro_taller_screen.dart';
import 'screens/mis_vehiculos_screen.dart';
import 'screens/mis_tecnicos_screen.dart';

void main() {
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
        '/registro-taller': (context) => const RegistroTallerScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => DashboardScreen(token: token),
          );
        }
        if (settings.name == '/roles') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => RolesScreen(token: token),
          );
        }
        if (settings.name == '/permisos') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => PermisosScreen(token: token),
          );
        }
        if (settings.name == '/mis-vehiculos') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => MisVehiculosScreen(token: token),
          );
        }
        if (settings.name == '/mis-tecnicos') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => MisTecnicosScreen(token: token),
          );
        }
        return null;
      },
    );
  }
}