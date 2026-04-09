import 'package:flutter/material.dart';
import '../services/roles_service.dart';

class RolesScreen extends StatefulWidget {
  final String token;
  const RolesScreen({super.key, required this.token});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  final _rolesService = RolesService();
  List<dynamic> _roles = [];
  bool _cargando = true;
  String _error = '';
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarRoles();
  }

  Future<void> _cargarRoles() async {
    try {
      final roles = await _rolesService.listarRoles(widget.token);
      setState(() {
        _roles = roles;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar roles';
        _cargando = false;
      });
    }
  }

  Future<void> _crearRol() async {
    if (_nombreController.text.isEmpty) return;
    try {
      await _rolesService.crearRol(
        widget.token,
        _nombreController.text,
        _descripcionController.text,
      );
      _nombreController.clear();
      _descripcionController.clear();
      _cargarRoles();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rol creado correctamente'), backgroundColor: Color(0xFFE63946)),
      );
    } catch (e) {
      setState(() => _error = 'Error al crear rol');
    }
  }

  Future<void> _toggleRol(Map<String, dynamic> rol) async {
    try {
      await _rolesService.actualizarRol(
        widget.token,
        rol['id'],
        {'activo': !rol['activo']},
      );
      _cargarRoles();
    } catch (e) {
      setState(() => _error = 'Error al actualizar rol');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Gestión de Roles'),
        backgroundColor: const Color(0xFFE63946),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/permisos', arguments: widget.token),
            child: const Text('Permisos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE63946)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: const Color(0xFFF8D7DA), borderRadius: BorderRadius.circular(8)),
                      child: Text(_error, style: const TextStyle(color: Color(0xFF721C24))),
                    ),
                  // Crear nuevo rol
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Crear Nuevo Rol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            hintText: 'Nombre del rol',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE63946))),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descripcionController,
                          decoration: InputDecoration(
                            hintText: 'Descripción',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE63946))),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _crearRol,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE63946),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Crear Rol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Lista de roles
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Roles del Sistema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ..._roles.map((rol) => ListTile(
                          title: Text(rol['nombre'], style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(rol['descripcion'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: rol['activo'] ? const Color(0xFFD4EDDA) : const Color(0xFFF8D7DA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  rol['activo'] ? 'Activo' : 'Inactivo',
                                  style: TextStyle(
                                    color: rol['activo'] ? const Color(0xFF155724) : const Color(0xFF721C24),
                                    fontSize: 12, fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => _toggleRol(rol),
                                child: Text(
                                  rol['activo'] ? 'Desactivar' : 'Activar',
                                  style: const TextStyle(color: Color(0xFFE63946)),
                                ),
                              ),
                            ],
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
}