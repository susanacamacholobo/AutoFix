import 'package:flutter/material.dart';
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  final String token;
  const DashboardScreen({super.key, required this.token});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _rol = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _decodeToken();
  }

  void _decodeToken() {
    try {
      final parts = widget.token.split('.');
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = jsonDecode(payload);
      setState(() {
        _rol = (data['rol'] ?? '').toString().toLowerCase();
        _email = data['sub'] ?? '';
      });
    } catch (e) {
      _rol = '';
    }
  }

  void _cerrarSesion() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoFix'),
        backgroundColor: const Color(0xFFE63946),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          if (_rol == 'conductor' || _rol == 'administrador')
            IconButton(
              icon: const Icon(Icons.directions_car),
              tooltip: 'Mis Vehículos',
              onPressed: () => Navigator.pushNamed(context, '/mis-vehiculos', arguments: widget.token),
            ),
          if (_rol == 'taller' || _rol == 'administrador')
            IconButton(
              icon: const Icon(Icons.engineering),
              tooltip: 'Mis Técnicos',
              onPressed: () => Navigator.pushNamed(context, '/mis-tecnicos', arguments: widget.token),
            ),
          if (_rol == 'administrador')
            IconButton(
              icon: const Icon(Icons.manage_accounts),
              tooltip: 'Gestionar Roles',
              onPressed: () => Navigator.pushNamed(context, '/roles', arguments: widget.token),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚗', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Bienvenido a AutoFix!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_rol == 'conductor')
              const Text('Reporta emergencias vehiculares desde aquí.', style: TextStyle(color: Colors.grey)),
            if (_rol == 'administrador')
              const Text('Panel de administración del sistema.', style: TextStyle(color: Colors.grey)),
            if (_rol == 'taller')
              const Text('Gestiona las solicitudes de asistencia.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}