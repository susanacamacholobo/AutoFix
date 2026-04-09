import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/roles_screen.dart';
import 'screens/permisos_screen.dart';

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
        '/dashboard': (context) => const DashboardScreen(),
      },
      onGenerateRoute: (settings) {
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
        return null;
      },
    );
  }
}