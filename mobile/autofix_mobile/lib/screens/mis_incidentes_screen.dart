import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  dynamic _incidenteSeleccionado;
  Timer? _timer;
  Map<int, Map<String, dynamic>> _tiemposEstimados = {};

  static const String baseUrl =
      'https://autofix-production-0c6c.up.railway.app';

  @override
  void initState() {
    super.initState();
    _cargarIncidentes();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _cargarIncidentes(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarIncidentes() async {
    try {
      final incidentes = await _incidenteService.listarMisIncidentes(
        widget.token,
      );
      setState(() {
        _incidentes = incidentes;
        _cargando = false;
      });
      // Cargar tiempos estimados para incidentes con técnico asignado
      for (final incidente in incidentes) {
        if (incidente['tecnico_id'] != null &&
            incidente['estado'] != 'atendido') {
          _cargarTiempoEstimado(incidente['id']);
        }
      }
    } catch (e) {
      setState(() => _cargando = false);
    }
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

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return const Color(0xFFF59E0B);
      case 'en_proceso':
        return const Color(0xFF3B82F6);
      case 'atendido':
        return const Color(0xFF10B981);
      case 'rechazado':
        return const Color(0xFFE63946);
      default:
        return Colors.grey;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_proceso':
        return 'En Proceso';
      case 'atendido':
        return 'Atendido';
      case 'rechazado':
        return 'Rechazado';
      default:
        return estado;
    }
  }

  String _getTipoEmoji(String? tipo) {
    switch (tipo) {
      case 'bateria':
      case 'batería':
        return '🔋';
      case 'llanta':
        return '🔧';
      case 'grua':
      case 'grúa':
        return '🚗';
      case 'choque':
        return '💥';
      case 'motor':
        return '⚙️';
      default:
        return '🚨';
    }
  }

  void _verDetalle(dynamic incidente) {
    setState(() => _incidenteSeleccionado = incidente);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetalle(incidente),
    );
  }

  List<Map<String, dynamic>> _getPasos(dynamic incidente) {
    final tieneResumen = incidente['resumen_ia'] != null;
    final tieneTaller = incidente['taller_id'] != null;
    final tieneTecnico = incidente['tecnico_id'] != null;
    final atendido = incidente['estado'] == 'atendido';
    final tiempoEstimado = _tiemposEstimados[incidente['id']];
    final minutos = tiempoEstimado?['minutos'];

    return [
      {
        'icono': '✅',
        'titulo': 'Solicitud registrada',
        'completado': true,
        'esActual': !tieneResumen,
        'subtitulo': tieneResumen
            ? 'Solicitud registrada'
            : 'Estamos procesando tu solicitud',
      },
      {
        'icono': tieneResumen ? '✅' : '⏳',
        'titulo': tieneResumen ? 'Solicitud procesada' : 'Procesando solicitud',
        'completado': tieneResumen,
        'esActual': tieneResumen && !tieneTaller,
        'subtitulo': tieneResumen
            ? (tieneTaller
                  ? 'Solicitud procesada'
                  : 'Estamos conectándote con un taller')
            : 'Analizando tu emergencia con IA...',
      },
      {
        'icono': tieneTaller ? '🏪' : '🔍',
        'titulo': tieneTaller ? 'Taller asignado' : 'Taller asignado',
        'completado': tieneTaller,
        'esActual': tieneTaller && !tieneTecnico && !atendido,
        'subtitulo': tieneTaller
            ? (tieneTecnico
                  ? 'Ya tienes un taller asignado'
                  : minutos != null
                  ? 'Tiempo estimado: $minutos min — Pronto se te asignará un técnico'
                  : 'Pronto se te asignará un técnico')
            : '',
      },
      {
        'icono': '👨‍🔧',
        'titulo': 'Técnico en camino',
        'completado': tieneTecnico,
        'esActual': tieneTecnico && !atendido,
        'subtitulo': tieneTecnico
            ? (atendido
                  ? 'El técnico llegó'
                  : minutos != null
                  ? 'El técnico está en camino — llega en $minutos min'
                  : 'El técnico está en camino')
            : '',
      },
      {
        'icono': atendido ? '✅' : '🏁',
        'titulo': 'Servicio completado',
        'completado': atendido,
        'esActual': atendido,
        'subtitulo': atendido ? '¡Tu vehículo ha sido atendido!' : '',
      },
    ];
  }

  Widget _buildDetalle(dynamic incidente) {
    final pasos = _getPasos(incidente);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _getTipoEmoji(incidente['tipo']),
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Emergencia #${incidente['id']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(
                        incidente['estado'],
                      ).withOpacity(0.15),
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
              const SizedBox(height: 24),

              // LÍNEA DE TIEMPO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: List.generate(pasos.length, (index) {
                    final paso = pasos[index];
                    final completado = paso['completado'] as bool;
                    final esActual = paso['esActual'] as bool;
                    final esUltimo = index == pasos.length - 1;
                    final subtitulo = paso['subtitulo'] as String;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: completado
                                    ? const Color(0xFFE63946)
                                    : esActual
                                    ? const Color(0xFFE63946).withOpacity(0.3)
                                    : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  paso['icono'] as String,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            if (!esUltimo)
                              Container(
                                width: 2,
                                height: 40,
                                color:
                                    completado &&
                                        (index + 1 < pasos.length &&
                                            (pasos[index + 1]['completado']
                                                as bool))
                                    ? const Color(0xFFE63946)
                                    : Colors.grey.shade300,
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  paso['titulo'] as String,
                                  style: TextStyle(
                                    fontWeight: esActual || completado
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: completado || esActual
                                        ? const Color(0xFF333333)
                                        : Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                if (subtitulo.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitulo,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: esActual && !completado
                                          ? const Color(0xFFE63946)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              _buildInfoRow('Tipo', incidente['tipo'] ?? 'Sin clasificar'),
              _buildInfoRow('Prioridad', incidente['prioridad'] ?? 'media'),
              _buildInfoRow(
                'Descripción',
                incidente['descripcion'] ?? 'Sin descripción',
              ),
              _buildInfoRow(
                'Fecha',
                incidente['fecha_creacion']?.substring(0, 10) ?? '',
              ),

              if (incidente['resumen_ia'] != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Análisis de IA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FF),
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                      left: BorderSide(color: Color(0xFFE63946), width: 3),
                    ),
                  ),
                  child: Text(
                    incidente['resumen_ia'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF444444),
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _cargarIncidentes();
                  },
                  icon: const Icon(Icons.refresh, color: Color(0xFFE63946)),
                  label: const Text(
                    'Actualizar estado',
                    style: TextStyle(color: Color(0xFFE63946)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE63946)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF333333)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Mis Emergencias'),
        backgroundColor: const Color(0xFFE63946),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarIncidentes,
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE63946)),
            )
          : _incidentes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎉', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 16),
                  Text(
                    'No tienes emergencias registradas',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarIncidentes,
              color: const Color(0xFFE63946),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _incidentes.length,
                itemBuilder: (context, index) {
                  final incidente = _incidentes[index];
                  return GestureDetector(
                    onTap: () => _verDetalle(incidente),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _getTipoEmoji(incidente['tipo']),
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    incidente['tipo'] ?? 'Sin clasificar',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getEstadoColor(
                                    incidente['estado'],
                                  ).withOpacity(0.15),
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
                            Text(
                              incidente['descripcion'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Prioridad: ${incidente['prioridad']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                incidente['fecha_creacion']?.substring(0, 10) ??
                                    '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          if (incidente['taller_id'] != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.store,
                                  size: 14,
                                  color: Color(0xFFE63946),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Taller asignado',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFE63946),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
