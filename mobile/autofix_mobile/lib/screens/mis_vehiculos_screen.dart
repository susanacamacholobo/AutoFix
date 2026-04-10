import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/vehiculos_service.dart';

class MisVehiculosScreen extends StatefulWidget {
  final String token;
  const MisVehiculosScreen({super.key, required this.token});

  @override
  State<MisVehiculosScreen> createState() => _MisVehiculosScreenState();
}

class _MisVehiculosScreenState extends State<MisVehiculosScreen> {
  final _vehiculosService = VehiculosService();
  List<dynamic> _vehiculos = [];
  bool _cargando = true;
  bool _mostrarFormulario = false;
  String _error = '';
  String _exito = '';

  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anioController = TextEditingController();
  final _placaController = TextEditingController();
  final _colorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarVehiculos();
  }

  Future<void> _cargarVehiculos() async {
    try {
      final vehiculos = await _vehiculosService.listarMisVehiculos(widget.token);
      setState(() {
        _vehiculos = vehiculos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar vehículos';
        _cargando = false;
      });
    }
  }

  Future<void> _agregarVehiculo() async {
    if (_marcaController.text.isEmpty || _modeloController.text.isEmpty || _placaController.text.isEmpty) {
      setState(() => _error = 'Completa los campos obligatorios');
      return;
    }

    try {
      // Obtener usuario actual
      final payload = _decodeToken();
      await _vehiculosService.crearVehiculo(widget.token, {
        'marca': _marcaController.text,
        'modelo': _modeloController.text,
        'anio': int.tryParse(_anioController.text),
        'placa': _placaController.text,
        'color': _colorController.text,
        'usuario_id': payload['id'],
      });

      _marcaController.clear();
      _modeloController.clear();
      _anioController.clear();
      _placaController.clear();
      _colorController.clear();

      setState(() {
        _mostrarFormulario = false;
        _exito = 'Vehículo registrado correctamente';
      });

      _cargarVehiculos();
      Future.delayed(const Duration(seconds: 3), () => setState(() => _exito = ''));
    } catch (e) {
      setState(() => _error = 'Error al registrar vehículo');
    }
  }

  Future<void> _eliminarVehiculo(int id) async {
    try {
      await _vehiculosService.eliminarVehiculo(widget.token, id);
      setState(() => _exito = 'Vehículo eliminado correctamente');
      _cargarVehiculos();
      Future.delayed(const Duration(seconds: 3), () => setState(() => _exito = ''));
    } catch (e) {
      setState(() => _error = 'Error al eliminar vehículo');
    }
  }

  Map<String, dynamic> _decodeToken() {
    final parts = widget.token.split('.');
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return Map<String, dynamic>.from(
      payload.replaceAll(RegExp(r'[{}]'), '').split(',').fold({}, (map, item) {
        final parts = item.split(':');
        if (parts.length == 2) map[parts[0].trim().replaceAll('"', '')] = parts[1].trim().replaceAll('"', '');
        return map;
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Mis Vehículos'),
        backgroundColor: const Color(0xFFE63946),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE63946)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_exito.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: const Color(0xFFD4EDDA), borderRadius: BorderRadius.circular(8)),
                      child: Text(_exito, style: const TextStyle(color: Color(0xFF155724))),
                    ),
                  if (_error.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: const Color(0xFFF8D7DA), borderRadius: BorderRadius.circular(8)),
                      child: Text(_error, style: const TextStyle(color: Color(0xFF721C24))),
                    ),
                  ElevatedButton(
                    onPressed: () => setState(() => _mostrarFormulario = !_mostrarFormulario),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE63946),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(_mostrarFormulario ? 'Cancelar' : '+ Agregar Vehículo', style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  if (_mostrarFormulario)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Registrar Nuevo Vehículo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildInput(_marcaController, 'Marca *')),
                              const SizedBox(width: 12),
                              Expanded(child: _buildInput(_modeloController, 'Modelo *')),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: _buildInput(_anioController, 'Año', type: TextInputType.number)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildInput(_placaController, 'Placa *')),
                            ],
                          ),
                          _buildInput(_colorController, 'Color'),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _agregarVehiculo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE63946),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Guardar Vehículo', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mis Vehículos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (_vehiculos.isEmpty)
                          const Center(child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No tienes vehículos registrados aún.', style: TextStyle(color: Colors.grey)),
                          ))
                        else
                          ..._vehiculos.map((v) => ListTile(
                            leading: const Text('🚗', style: TextStyle(fontSize: 24)),
                            title: Text('${v['marca']} ${v['modelo']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text('Placa: ${v['placa']} • ${v['color'] ?? ''} • ${v['anio'] ?? ''}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Color(0xFFE63946)),
                              onPressed: () => _eliminarVehiculo(v['id']),
                            ),
                          )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: type,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE63946))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}