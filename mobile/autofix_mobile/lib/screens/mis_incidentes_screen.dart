import 'package:flutter/material.dart';
import '../services/incidente_service.dart';

class MisIncidentesScreen extends StatefulWidget {
  final String token;
  const MisIncidentesScreen({super.key, required this.token});

  @override
  State<MisIncidentesScreen> createState() => _MisIncidentesScreenState();
}

class _MisIncidentesScreenState extends State<MisIncidentesScreen> {
  final _incidenteService = IncidenteService();
  List<dynamic> _incidentes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarIncidentes();
  }

  Future<void> _cargarIncidentes() async {
    try {
      final incidentes = await _incidenteService.listarMisIncidentes(widget.token);
      setState(() {
        _incidentes = incidentes;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente': return const Color(0xFFF59E0B);
      case 'en_proceso': return const Color(0xFF3B82F6);
      case 'atendido': return const Color(0xFF10B981);
      case 'rechazado': return const Color(0xFFE63946);
      default: return Colors.grey;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'pendiente': return 'Pendiente';
      case 'en_proceso': return 'En Proceso';
      case 'atendido': return 'Atendido';
      case 'rechazado': return 'Rechazado';
      default: return estado;
    }
  }

  String _getTipoEmoji(String? tipo) {
    switch (tipo) {
      case 'bateria': return '🔋';
      case 'llanta': return '🔧';
      case 'grua': return '🚗';
      default: return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Mis Emergencias'),
        backgroundColor: const Color(0xFFE63946),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE63946)))
          : _incidentes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🎉', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 16),
                      Text('No tienes emergencias registradas',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _incidentes.length,
                  itemBuilder: (context, index) {
                    final incidente = _incidentes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(_getTipoEmoji(incidente['tipo']),
                                      style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 8),
                                  Text(
                                    incidente['tipo'] ?? 'Sin clasificar',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getEstadoColor(incidente['estado']).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getEstadoTexto(incidente['estado']),
                                  style: TextStyle(
                                    color: _getEstadoColor(incidente['estado']),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (incidente['descripcion'] != null) ...[
                            const SizedBox(height: 8),
                            Text(incidente['descripcion'],
                                style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Prioridad: ${incidente['prioridad']}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                incidente['fecha_creacion']?.substring(0, 10) ?? '',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}