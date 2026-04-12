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
  String _nombre = '';

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
        _nombre = data['nombre'] ?? _email;
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
      body: _rol == 'conductor'
          ? _buildConductorDashboard()
          : _buildDefaultDashboard(),
    );
  }

  Widget _buildConductorDashboard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¡Hola, $_nombre!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 32),

          // Botón de emergencia
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/reportar-emergencia', arguments: widget.token),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE63946),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE63946).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Column(
                children: [
                  Text('🚨', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text('REPORTAR EMERGENCIA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      )),
                  SizedBox(height: 4),
                  Text('Toca aquí si necesitas ayuda mecánica',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Botones secundarios
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/mis-vehiculos', arguments: widget.token),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: const Column(
                      children: [
                        Text('🚗', style: TextStyle(fontSize: 28)),
                        SizedBox(height: 8),
                        Text('Mis Vehículos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/mis-incidentes', arguments: widget.token),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: const Column(
                      children: [
                        Text('📋', style: TextStyle(fontSize: 28)),
                        SizedBox(height: 8),
                        Text('Mis Emergencias', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultDashboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔧', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('Bienvenido a AutoFix!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_rol == 'taller')
            const Text('Gestiona las solicitudes de asistencia.',
                style: TextStyle(color: Colors.grey)),
          if (_rol == 'administrador')
            const Text('Panel de administración del sistema.',
                style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}