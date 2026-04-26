import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  final String token;
  const DashboardScreen({super.key, required this.token});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _email = '';
  String _nombre = '';
  dynamic _incidenteActivo;
  Timer? _timer;
  Map<int, Map<String, dynamic>> _tiemposEstimados = {};

  static const String baseUrl = 'https://autofix-production-0c6c.up.railway.app';

  @override
  void initState() {
    super.initState();
    _decodeToken();
    _cargarIncidenteActivo();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _cargarIncidenteActivo(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _decodeToken() {
    try {
      final parts = widget.token.split('.');
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = jsonDecode(payload);
      setState(() {
        _email = data['sub'] ?? '';
        _nombre = data['nombre'] ?? _email;
      });
    } catch (e) {}
  }

  Future<void> _cargarIncidenteActivo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/incidentes/mis-incidentes'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final incidentes = jsonDecode(response.body) as List;
        final activos = incidentes
            .where((i) => i['estado'] != 'atendido' && i['estado'] != 'rechazado')
            .toList();
        setState(() {
          _incidenteActivo = activos.isNotEmpty ? activos.last : null;
        });
        if (_incidenteActivo != null && _incidenteActivo['tecnico_id'] != null) {
          _cargarTiempoEstimado(_incidenteActivo['id']);
        }
      }
    } catch (e) {}
  }

  Future<void> _cargarTiempoEstimado(int incidenteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ia/tiempo-estimado/$incidenteId'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _tiemposEstimados[incidenteId] = data;
        });
      }
    } catch (e) {}
  }

  void _cerrarSesion() {
    _timer?.cancel();
    Navigator.pushReplacementNamed(context, '/login');
  }

  String _getTipoEmoji(String? tipo) {
    switch (tipo) {
      case 'bateria':
      case 'batería': return '🔋';
      case 'llanta': return '🔧';
      case 'grua':
      case 'grúa': return '🚗';
      case 'choque': return '💥';
      case 'motor': return '⚙️';
      default: return '🚨';
    }
  }

  List<Map<String, dynamic>> _getPasosHorizontal(dynamic incidente) {
    final tieneResumen = incidente['resumen_ia'] != null;
    final tieneTaller = incidente['taller_id'] != null;
    final tieneTecnico = incidente['tecnico_id'] != null;
    final atendido = incidente['estado'] == 'atendido';

    return [
      {
        'icono': tieneResumen ? '✅' : '⏳',
        'label': tieneResumen ? 'Procesada' : 'Procesando',
        'completado': tieneResumen,
      },
      {
        'icono': tieneTaller ? '🏪' : '🔍',
        'label': tieneTaller ? 'Taller' : 'Buscando',
        'completado': tieneTaller,
      },
      {
        'icono': '👨‍🔧',
        'label': tieneTecnico ? 'Técnico' : 'Asignando',
        'completado': tieneTecnico,
      },
      {
        'icono': atendido ? '✅' : '🛵',
        'label': atendido ? 'Llegó' : 'En camino',
        'completado': tieneTecnico,
      },
      {
        'icono': '✅',
        'label': 'Listo',
        'completado': atendido,
      },
    ];
  }

  Widget _buildLineaTiempoHorizontal(dynamic incidente) {
    final tieneResumen = incidente['resumen_ia'] != null;
    final tieneTaller = incidente['taller_id'] != null;
    final tieneTecnico = incidente['tecnico_id'] != null;
    final atendido = incidente['estado'] == 'atendido';

    final tiempoEstimado = _tiemposEstimados[incidente['id']];
    final minutos = tiempoEstimado?['minutos'];

    String titulo = '';
    String subtitulo = '';

    if (atendido) {
      titulo = 'Servicio completado';
      subtitulo = '¡Tu vehículo ha sido atendido!';
    } else if (tieneTecnico) {
      titulo = 'Técnico en camino';
      subtitulo = minutos != null
          ? 'El técnico llega en aproximadamente $minutos min'
          : 'El técnico está en camino';
    } else if (tieneTaller) {
      titulo = 'Asignándote un técnico';
      subtitulo = 'Pronto se te asignará un técnico';
    } else if (tieneResumen) {
      titulo = 'Buscando taller';
      subtitulo = 'Estamos conectándote con un taller';
    } else {
      titulo = 'Procesando solicitud';
      subtitulo = 'Estamos procesando tu solicitud...';
    }

    final pasos = _getPasosHorizontal(incidente);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/mis-incidentes', arguments: widget.token),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
          border: Border.all(color: const Color(0xFFE63946).withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(_getTipoEmoji(incidente['tipo']), style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFE63946)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(pasos.length * 2 - 1, (index) {
                if (index.isOdd) {
                  final pasoIndex = index ~/ 2;
                  final completado = pasos[pasoIndex]['completado'] as bool &&
                      pasos[pasoIndex + 1]['completado'] as bool;
                  return Expanded(
                    child: Container(
                      height: 2,
                      color: completado ? const Color(0xFFE63946) : Colors.grey.shade300,
                    ),
                  );
                } else {
                  final pasoIndex = index ~/ 2;
                  final paso = pasos[pasoIndex];
                  final completado = paso['completado'] as bool;
                  return Column(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: completado ? const Color(0xFFE63946) : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(paso['icono'] as String,
                              style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        paso['label'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color: completado ? const Color(0xFFE63946) : Colors.grey,
                          fontWeight: completado ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }
              }),
            ),
            const SizedBox(height: 10),
            Text(
              subtitulo,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
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
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¡Hola, $_nombre!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),

            if (_incidenteActivo != null)
              _buildLineaTiempoHorizontal(_incidenteActivo),

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
                    ),
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
                          Text('Mis Vehículos',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                          Text('Mis Emergencias',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}