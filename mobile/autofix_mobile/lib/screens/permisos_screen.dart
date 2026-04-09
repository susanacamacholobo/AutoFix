import 'package:flutter/material.dart';
import '../services/roles_service.dart';
import '../services/permisos_service.dart';

class PermisosScreen extends StatefulWidget {
  final String token;
  const PermisosScreen({super.key, required this.token});

  @override
  State<PermisosScreen> createState() => _PermisosScreenState();
}

class _PermisosScreenState extends State<PermisosScreen> {
  final _rolesService = RolesService();
  final _permisosService = PermisosService();
  List<dynamic> _roles = [];
  List<dynamic> _permisos = [];
  List<dynamic> _permisosDelRol = [];
  Map<String, dynamic>? _rolSeleccionado;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final roles = await _rolesService.listarRoles(widget.token);
      final permisos = await _permisosService.listarPermisos(widget.token);
      setState(() {
        _roles = roles;
        _permisos = permisos;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _seleccionarRol(Map<String, dynamic> rol) async {
    setState(() => _rolSeleccionado = rol);
    try {
      final permisos = await _permisosService.listarPermisosPorRol(widget.token, rol['id']);
      setState(() => _permisosDelRol = permisos);
    } catch (e) {
      setState(() => _permisosDelRol = []);
    }
  }

  bool _tienePermiso(int permisoId) {
    return _permisosDelRol.any((p) => p['id'] == permisoId);
  }

  Future<void> _togglePermiso(Map<String, dynamic> permiso) async {
    if (_rolSeleccionado == null) return;
    try {
      if (_tienePermiso(permiso['id'])) {
        await _permisosService.removerPermiso(widget.token, _rolSeleccionado!['id'], permiso['id']);
        setState(() => _permisosDelRol.removeWhere((p) => p['id'] == permiso['id']));
      } else {
        await _permisosService.asignarPermiso(widget.token, _rolSeleccionado!['id'], permiso['id']);
        setState(() => _permisosDelRol.add(permiso));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar permiso'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Gestión de Permisos'),
        backgroundColor: const Color(0xFFE63946),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE63946)))
          : Row(
              children: [
                // Panel de roles
                Container(
                  width: 160,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Roles', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._roles.map((rol) => GestureDetector(
                        onTap: () => _seleccionarRol(rol),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _rolSeleccionado?['id'] == rol['id']
                                ? const Color(0xFFFFF0F0)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _rolSeleccionado?['id'] == rol['id']
                                  ? const Color(0xFFE63946)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(rol['nombre'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                      )),
                    ],
                  ),
                ),
                // Panel de permisos
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: _rolSeleccionado == null
                        ? const Center(child: Text('Selecciona un rol', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _permisos.length,
                            itemBuilder: (context, index) {
                              final permiso = _permisos[index];
                              return SwitchListTile(
                                title: Text(permiso['nombre'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                subtitle: Text(permiso['descripcion'] ?? '', style: const TextStyle(fontSize: 11)),
                                value: _tienePermiso(permiso['id']),
                                activeColor: const Color(0xFFE63946),
                                onChanged: (_) => _togglePermiso(permiso),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}