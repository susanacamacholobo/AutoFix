import 'package:flutter/material.dart';
import '../services/talleres_service.dart';

class MisTecnicosScreen extends StatefulWidget {
  final String token;
  const MisTecnicosScreen({super.key, required this.token});

  @override
  State<MisTecnicosScreen> createState() => _MisTecnicosScreenState();
}

class _MisTecnicosScreenState extends State<MisTecnicosScreen> {
  final _talleresService = TalleresService();
  List<dynamic> _tecnicos = [];
  int _tallerId = 0;
  bool _cargando = true;
  bool _mostrarFormulario = false;
  String _error = '';
  String _exito = '';

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _especialidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _obtenerTaller();
  }

  Future<void> _obtenerTaller() async {
    try {
      final taller = await _talleresService.obtenerMiTaller(widget.token);
      setState(() => _tallerId = taller['id']);
      await _cargarTecnicos();
    } catch (e) {
      setState(() {
        _error = 'Error al obtener datos del taller';
        _cargando = false;
      });
    }
  }

  Future<void> _cargarTecnicos() async {
    try {
      final tecnicos = await _talleresService.listarTecnicos(widget.token, _tallerId);
      setState(() {
        _tecnicos = tecnicos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar técnicos';
        _cargando = false;
      });
    }
  }

  Future<void> _agregarTecnico() async {
    if (_nombreController.text.isEmpty || _apellidoController.text.isEmpty) {
      setState(() => _error = 'Nombre y apellido son obligatorios');
      return;
    }

    try {
      await _talleresService.crearTecnico(widget.token, _tallerId, {
        'taller_id': _tallerId,
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'telefono': _telefonoController.text,
        'especialidad': _especialidadController.text,
      });

      _nombreController.clear();
      _apellidoController.clear();
      _telefonoController.clear();
      _especialidadController.clear();

      setState(() {
        _mostrarFormulario = false;
        _exito = 'Técnico registrado correctamente';
      });

      await _cargarTecnicos();
      Future.delayed(const Duration(seconds: 3), () => setState(() => _exito = ''));
    } catch (e) {
      setState(() => _error = 'Error al registrar técnico');
    }
  }

  Future<void> _toggleDisponibilidad(Map<String, dynamic> tecnico) async {
    try {
      await _talleresService.actualizarTecnico(
        widget.token, _tallerId, tecnico['id'],
        {'disponible': !tecnico['disponible']},
      );
      await _cargarTecnicos();
      setState(() => _exito = 'Técnico actualizado correctamente');
      Future.delayed(const Duration(seconds: 3), () => setState(() => _exito = ''));
    } catch (e) {
      setState(() => _error = 'Error al actualizar técnico');
    }
  }

  Future<void> _toggleActivo(Map<String, dynamic> tecnico) async {
    try {
      await _talleresService.actualizarTecnico(
        widget.token, _tallerId, tecnico['id'],
        {'activo': !tecnico['activo']},
      );
      await _cargarTecnicos();
      setState(() => _exito = 'Técnico ${tecnico['activo'] ? 'desactivado' : 'activado'} correctamente');
      Future.delayed(const Duration(seconds: 3), () => setState(() => _exito = ''));
    } catch (e) {
      setState(() => _error = 'Error al actualizar técnico');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Mis Técnicos'),
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
                    child: Text(_mostrarFormulario ? 'Cancelar' : '+ Agregar Técnico',
                        style: const TextStyle(color: Colors.white)),
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
                          const Text('Registrar Nuevo Técnico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildInput(_nombreController, 'Nombre *')),
                              const SizedBox(width: 12),
                              Expanded(child: _buildInput(_apellidoController, 'Apellido *')),
                            ],
                          ),
                          _buildInput(_telefonoController, 'Teléfono', type: TextInputType.phone),
                          _buildInput(_especialidadController, 'Especialidad'),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _agregarTecnico,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE63946),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Guardar Técnico', style: TextStyle(color: Colors.white)),
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
                        const Text('Mis Técnicos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (_tecnicos.isEmpty)
                          const Center(child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No tienes técnicos registrados aún.', style: TextStyle(color: Colors.grey)),
                          ))
                        else
                          ..._tecnicos.map((t) => Opacity(
                            opacity: t['activo'] ? 1.0 : 0.5,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8),
                                color: t['activo'] ? Colors.white : Colors.grey.shade100,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${t['nombre']} ${t['apellido']}',
                                          style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: t['disponible'] ? const Color(0xFFD4EDDA) : const Color(0xFFF8D7DA),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          t['disponible'] ? 'Disponible' : 'No disponible',
                                          style: TextStyle(
                                            color: t['disponible'] ? const Color(0xFF155724) : const Color(0xFF721C24),
                                            fontSize: 11, fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (t['especialidad'] != null)
                                    Text(t['especialidad'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  if (t['telefono'] != null)
                                    Text(t['telefono'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () => _toggleDisponibilidad(t),
                                        child: Text(
                                          t['disponible'] ? 'No disponible' : 'Disponible',
                                          style: const TextStyle(color: Color(0xFFE63946)),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => _toggleActivo(t),
                                        child: Text(
                                          t['activo'] ? 'Desactivar' : 'Activar',
                                          style: TextStyle(color: t['activo'] ? Colors.orange : Colors.green),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE63946))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}