import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      home: const SplashScreen(),
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await Future.delayed(const Duration(seconds: 1));
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/dashboard', arguments: token);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFE63946),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('AutoFix',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                )),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}