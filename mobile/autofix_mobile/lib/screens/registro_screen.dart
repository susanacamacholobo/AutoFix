import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/vehiculos_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _authService = AuthService();
  final _vehiculosService = VehiculosService();

  int _paso = 1;
  String _tipoUsuario = '';
  bool _mostrarContrasena = false;
  bool _cargando = false;
  String _error = '';

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anioController = TextEditingController();
  final _placaController = TextEditingController();
  final _colorController = TextEditingController();

  void _seleccionarTipo(String tipo) {
    setState(() {
      _tipoUsuario = tipo;
      _paso = 2;
    });
  }

  void _siguientePaso() {
    setState(() => _error = '');
    if (_nombreController.text.isEmpty || _apellidoController.text.isEmpty ||
        _emailController.text.isEmpty || _contrasenaController.text.isEmpty) {
      setState(() => _error = 'Por favor completa todos los campos obligatorios');
      return;
    }
    if (_contrasenaController.text != _confirmarContrasenaController.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    if (_contrasenaController.text.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    setState(() => _paso = 3);
  }

  Future<void> _registrarse() async {
    setState(() => _error = '');
    if (_marcaController.text.isEmpty || _modeloController.text.isEmpty || _placaController.text.isEmpty) {
      setState(() => _error = 'Por favor completa los campos obligatorios del vehículo');
      return;
    }

    setState(() => _cargando = true);

    try {
      // Registrar usuario
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/usuarios/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': _nombreController.text,
          'apellido': _apellidoController.text,
          'email': _emailController.text,
          'telefono': _telefonoController.text,
          'contrasena': _contrasenaController.text,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        setState(() {
          _error = error['detail'] ?? 'Error al crear la cuenta';
          _cargando = false;
        });
        return;
      }

      final usuario = jsonDecode(response.body);

      // Login automático
      final loginRespuesta = await _authService.login(
        _emailController.text,
        _contrasenaController.text,
      );

      final token = loginRespuesta['access_token'];

      // Registrar vehículo
      await _vehiculosService.crearVehiculo(token, {
        'marca': _marcaController.text,
        'modelo': _modeloController.text,
        'anio': int.tryParse(_anioController.text),
        'placa': _placaController.text,
        'color': _colorController.text,
        'usuario_id': usuario['id'],
      });

      setState(() => _cargando = false);
      Navigator.pushReplacementNamed(context, '/dashboard', arguments: token);

    } catch (e) {
      setState(() {
        _error = 'Error al crear la cuenta';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              color: const Color(0xFFE63946),
              child: Column(
                children: [
                  const Text('AutoFix', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text(
                    _paso == 1 ? '¿Cómo quieres usar AutoFix?' : _paso == 2 ? 'Datos personales' : 'Tu vehículo',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // PASO 1
                  if (_paso == 1) ...[
                    const Text('Crear cuenta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Selecciona cómo vas a usar la plataforma', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _seleccionarTipo('conductor'),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE63946), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                children: [
                                  Text('🚗', style: TextStyle(fontSize: 32)),
                                  SizedBox(height: 8),
                                  Text('Soy Conductor', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text('Necesito asistencia mecánica', style: TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, '/registro-taller'),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE63946), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                children: [
                                  Text('🔧', style: TextStyle(fontSize: 32)),
                                  SizedBox(height: 8),
                                  Text('Tengo un Taller', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text('Quiero ofrecer servicios', style: TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿Ya tienes cuenta? ', style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text('Inicia sesión', style: TextStyle(color: Color(0xFFE63946), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],

                  // PASO 2
                  if (_paso == 2) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(onPressed: () => setState(() => _paso = 1), child: const Text('← Volver', style: TextStyle(color: Color(0xFFE63946)))),
                        const Text('Paso 1 de 2', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Text('Tus datos personales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildInput(_nombreController, 'Nombre *')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInput(_apellidoController, 'Apellido *')),
                      ],
                    ),
                    _buildInput(_emailController, 'Email *', type: TextInputType.emailAddress),
                    _buildInput(_telefonoController, 'Teléfono', type: TextInputType.phone),
                    _buildPasswordInput(_contrasenaController, 'Contraseña *'),
                    _buildInput(_confirmarContrasenaController, 'Confirmar Contraseña *', obscure: true),
                    if (_error.isNotEmpty) _buildError(),
                    const SizedBox(height: 8),
                    _buildButton('Siguiente → Registrar Vehículo', _siguientePaso),
                  ],

                  // PASO 3
                  if (_paso == 3) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(onPressed: () => setState(() => _paso = 2), child: const Text('← Volver', style: TextStyle(color: Color(0xFFE63946)))),
                        const Text('Paso 2 de 2', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Text('Tu vehículo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Agrega al menos un vehículo para continuar', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 16),
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
                    if (_error.isNotEmpty) _buildError(),
                    const SizedBox(height: 8),
                    _buildButton(_cargando ? 'Creando cuenta...' : 'Crear Cuenta', _cargando ? null : _registrarse),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, {TextInputType type = TextInputType.text, bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF555555))),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: type,
            obscureText: obscure,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE63946))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF555555))),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: !_mostrarContrasena,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE63946))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(_mostrarContrasena ? Icons.visibility : Icons.visibility_off, color: const Color(0xFFE63946)),
                onPressed: () => setState(() => _mostrarContrasena = !_mostrarContrasena),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String texto, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE63946),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(texto, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(8)),
      child: Text(_error, style: const TextStyle(color: Color(0xFFE63946)), textAlign: TextAlign.center),
    );
  }
}