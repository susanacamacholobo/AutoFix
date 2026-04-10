import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/talleres_service.dart';
import '../services/auth_service.dart';

class RegistroTallerScreen extends StatefulWidget {
  const RegistroTallerScreen({super.key});

  @override
  State<RegistroTallerScreen> createState() => _RegistroTallerScreenState();
}

class _RegistroTallerScreenState extends State<RegistroTallerScreen> {
  final _talleresService = TalleresService();
  final _authService = AuthService();

  int _paso = 1;
  bool _mostrarContrasena = false;
  bool _cargando = false;
  String _error = '';

  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _especialidadController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  final _tecNombreController = TextEditingController();
  final _tecApellidoController = TextEditingController();
  final _tecTelefonoController = TextEditingController();
  final _tecEspecialidadController = TextEditingController();

  void _siguientePaso() {
    setState(() => _error = '');
    if (_nombreController.text.isEmpty || _emailController.text.isEmpty || _contrasenaController.text.isEmpty) {
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
    setState(() => _paso = 2);
  }

  Future<void> _registrarse() async {
    setState(() => _error = '');
    if (_tecNombreController.text.isEmpty || _tecApellidoController.text.isEmpty) {
      setState(() => _error = 'Por favor ingresa al menos un técnico');
      return;
    }

    setState(() => _cargando = true);

    try {
      final taller = await _talleresService.registrarTaller({
        'nombre': _nombreController.text,
        'email': _emailController.text,
        'telefono': _telefonoController.text,
        'direccion': _direccionController.text,
        'especialidad': _especialidadController.text,
        'contrasena': _contrasenaController.text,
      });

      // Login automático
      final loginRespuesta = await _authService.login(
        _emailController.text,
        _contrasenaController.text,
      );

      final token = loginRespuesta['access_token'];

      // Crear técnico
      await _talleresService.crearTecnico(token, taller['id'], {
        'taller_id': taller['id'],
        'nombre': _tecNombreController.text,
        'apellido': _tecApellidoController.text,
        'telefono': _tecTelefonoController.text,
        'especialidad': _tecEspecialidadController.text,
      });

      setState(() => _cargando = false);
      Navigator.pushReplacementNamed(context, '/dashboard', arguments: token);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              color: const Color(0xFFE63946),
              child: Column(
                children: [
                  const Text('AutoFix', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text(
                    _paso == 1 ? 'Datos del taller' : 'Tu primer técnico',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/registro'),
                          child: const Text('← Volver', style: TextStyle(color: Color(0xFFE63946))),
                        ),
                        const Text('Paso 1 de 2', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Text('Datos del Taller', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInput(_nombreController, 'Nombre del taller *'),
                    _buildInput(_emailController, 'Email *', type: TextInputType.emailAddress),
                    _buildInput(_telefonoController, 'Teléfono', type: TextInputType.phone),
                    _buildInput(_direccionController, 'Dirección'),
                    _buildInput(_especialidadController, 'Especialidad'),
                    _buildPasswordInput(_contrasenaController, 'Contraseña *'),
                    _buildInput(_confirmarContrasenaController, 'Confirmar Contraseña *', obscure: true),
                    if (_error.isNotEmpty) _buildError(),
                    const SizedBox(height: 8),
                    _buildButton('Siguiente → Registrar Técnico', _siguientePaso),
                  ],

                  // PASO 2
                  if (_paso == 2) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _paso = 1),
                          child: const Text('← Volver', style: TextStyle(color: Color(0xFFE63946))),
                        ),
                        const Text('Paso 2 de 2', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Text('Tu primer técnico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Agrega al menos un técnico para continuar', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildInput(_tecNombreController, 'Nombre *')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInput(_tecApellidoController, 'Apellido *')),
                      ],
                    ),
                    _buildInput(_tecTelefonoController, 'Teléfono', type: TextInputType.phone),
                    _buildInput(_tecEspecialidadController, 'Especialidad'),
                    if (_error.isNotEmpty) _buildError(),
                    const SizedBox(height: 8),
                    _buildButton(_cargando ? 'Registrando...' : 'Registrar Taller', _cargando ? null : _registrarse),
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