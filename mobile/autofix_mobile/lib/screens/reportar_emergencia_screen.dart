import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../services/incidente_service.dart';
import '../services/vehiculos_service.dart';

class ReportarEmergenciaScreen extends StatefulWidget {
  final String token;
  const ReportarEmergenciaScreen({super.key, required this.token});

  @override
  State<ReportarEmergenciaScreen> createState() => _ReportarEmergenciaScreenState();
}

class _ReportarEmergenciaScreenState extends State<ReportarEmergenciaScreen> {
  final _incidenteService = IncidenteService();
  final _vehiculosService = VehiculosService();
  final _imagePicker = ImagePicker();

  List<dynamic> _vehiculos = [];
  int? _vehiculoSeleccionado;
  String _tipoSeleccionado = '';
  bool _cargando = false;
  bool _cargandoVehiculos = true;
  bool _cargandoUbicacion = false;
  String _error = '';
  int _usuarioId = 0;
  double? _latitud;
  double? _longitud;
  String _ubicacionTexto = '';
  List<XFile> _fotos = [];

  final _descripcionController = TextEditingController();

  final List<Map<String, dynamic>> _tiposEmergencia = [
    {'tipo': 'bateria', 'emoji': '🔋', 'titulo': 'Se acabó la batería', 'descripcion': 'Mi vehículo no enciende por la batería'},
    {'tipo': 'llanta', 'emoji': '🔧', 'titulo': 'Llanta pinchada', 'descripcion': 'Tengo una llanta pinchada'},
    {'tipo': 'grua', 'emoji': '🚗', 'titulo': 'Necesito una grúa', 'descripcion': 'Mi vehículo no puede moverse, necesito grúa'},
    {'tipo': 'otro', 'emoji': '❓', 'titulo': 'Otra emergencia', 'descripcion': ''},
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final vehiculos = await _vehiculosService.listarMisVehiculos(widget.token);
      final parts = widget.token.split('.');
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      setState(() {
        _vehiculos = vehiculos;
        _usuarioId = payload['id'] is int ? payload['id'] : int.tryParse(payload['id'].toString()) ?? 0;
        _cargandoVehiculos = false;
      });
    } catch (e) {
      setState(() => _cargandoVehiculos = false);
    }
  }

  Future<void> _obtenerUbicacion() async {
    setState(() => _cargandoUbicacion = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Permisos de ubicación denegados permanentemente';
          _cargandoUbicacion = false;
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitud = position.latitude;
        _longitud = position.longitude;
        _ubicacionTexto = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
        _cargandoUbicacion = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al obtener ubicación';
        _cargandoUbicacion = false;
      });
    }
  }

  Future<void> _tomarFoto() async {
    final foto = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (foto != null) {
      setState(() => _fotos.add(foto));
    }
  }

  Future<void> _seleccionarFoto() async {
    final foto = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (foto != null) {
      setState(() => _fotos.add(foto));
    }
  }

  Future<void> _reportarEmergencia() async {
    if (_vehiculoSeleccionado == null) {
      setState(() => _error = 'Selecciona un vehículo');
      return;
    }
    if (_tipoSeleccionado.isEmpty) {
      setState(() => _error = 'Selecciona el tipo de emergencia');
      return;
    }

    setState(() {
      _cargando = true;
      _error = '';
    });

    try {
      final tipoData = _tiposEmergencia.firstWhere((t) => t['tipo'] == _tipoSeleccionado);
      final descripcionFinal = _tipoSeleccionado == 'otro'
          ? _descripcionController.text
          : tipoData['descripcion'];

      await _incidenteService.crearIncidente(widget.token, {
        'usuario_id': _usuarioId,
        'vehiculo_id': _vehiculoSeleccionado,
        'tipo': _tipoSeleccionado,
        'descripcion': descripcionFinal,
        'latitud': _latitud,
        'longitud': _longitud,
      });

      setState(() => _cargando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Emergencia reportada! Un taller te contactará pronto.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = 'Error al reportar emergencia';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Reportar Emergencia'),
        backgroundColor: const Color(0xFFE63946),
        foregroundColor: Colors.white,
      ),
      body: _cargandoVehiculos
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE63946)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seleccionar vehículo
                  _buildCard(
                    titulo: '¿Qué vehículo tiene el problema?',
                    child: Column(
                      children: _vehiculos.map((v) => GestureDetector(
                        onTap: () => setState(() => _vehiculoSeleccionado = v['id']),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _vehiculoSeleccionado == v['id'] ? const Color(0xFFE63946) : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: _vehiculoSeleccionado == v['id'] ? const Color(0xFFFFF0F0) : Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Text('🚗', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${v['marca']} ${v['modelo']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text('Placa: ${v['placa']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tipo de emergencia
                  _buildCard(
                    titulo: '¿Qué te pasó?',
                    child: Column(
                      children: [
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.3,
                          children: _tiposEmergencia.map((tipo) => GestureDetector(
                            onTap: () => setState(() => _tipoSeleccionado = tipo['tipo']),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _tipoSeleccionado == tipo['tipo'] ? const Color(0xFFE63946) : Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: _tipoSeleccionado == tipo['tipo'] ? const Color(0xFFFFF0F0) : Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(tipo['emoji'], style: const TextStyle(fontSize: 28)),
                                  const SizedBox(height: 6),
                                  Text(tipo['titulo'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          )).toList(),
                        ),
                        if (_tipoSeleccionado == 'otro') ...[
                          const SizedBox(height: 16),
                          const Align(alignment: Alignment.centerLeft, child: Text('Describe tu emergencia:', style: TextStyle(fontWeight: FontWeight.w500))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descripcionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Describe el problema de tu vehículo...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE63946))),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ubicación
                  _buildCard(
                    titulo: '📍 Confirmar ubicación',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_ubicacionTexto.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(color: const Color(0xFFD4EDDA), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFF155724), size: 18),
                                const SizedBox(width: 8),
                                Text(_ubicacionTexto, style: const TextStyle(color: Color(0xFF155724), fontSize: 13)),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _cargandoUbicacion ? null : _obtenerUbicacion,
                            icon: _cargandoUbicacion
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.my_location, color: Color(0xFFE63946)),
                            label: Text(
                              _ubicacionTexto.isEmpty ? 'Obtener mi ubicación' : 'Actualizar ubicación',
                              style: const TextStyle(color: Color(0xFFE63946)),
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
                  const SizedBox(height: 16),

                  // Fotos
                  _buildCard(
                    titulo: '📸 Adjuntar fotos',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_fotos.isNotEmpty) ...[
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _fotos.length,
                              itemBuilder: (context, index) => Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(File(_fotos[index].path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0, right: 8,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _fotos.removeAt(index)),
                                      child: Container(
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _tomarFoto,
                                icon: const Icon(Icons.camera_alt, color: Color(0xFFE63946)),
                                label: const Text('Cámara', style: TextStyle(color: Color(0xFFE63946))),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE63946))),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _seleccionarFoto,
                                icon: const Icon(Icons.photo_library, color: Color(0xFFE63946)),
                                label: const Text('Galería', style: TextStyle(color: Color(0xFFE63946))),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE63946))),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_error.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(8)),
                      child: Text(_error, style: const TextStyle(color: Color(0xFFE63946))),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _reportarEmergencia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE63946),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('🚨 Reportar Emergencia',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildCard({required String titulo, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}