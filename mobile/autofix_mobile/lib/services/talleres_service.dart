import 'dart:convert';
import 'package:http/http.dart' as http;

class TalleresService {
  final String baseUrl = 'https://autofix-production-0c6c.up.railway.app';

  Future<Map<String, dynamic>> registrarTaller(Map<String, dynamic> taller) async {
    final response = await http.post(
      Uri.parse('$baseUrl/talleres/registro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(taller),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Error al registrar taller');
    }
  }

  Future<Map<String, dynamic>> obtenerMiTaller(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/talleres/mi-taller'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener taller');
    }
  }

  Future<List<dynamic>> listarTecnicos(String token, int tallerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/talleres/$tallerId/tecnicos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar técnicos');
    }
  }

  Future<Map<String, dynamic>> crearTecnico(String token, int tallerId, Map<String, dynamic> tecnico) async {
    final response = await http.post(
      Uri.parse('$baseUrl/talleres/$tallerId/tecnicos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(tecnico),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear técnico');
    }
  }

  Future<Map<String, dynamic>> actualizarTecnico(String token, int tallerId, int tecnicoId, Map<String, dynamic> datos) async {
    final response = await http.put(
      Uri.parse('$baseUrl/talleres/$tallerId/tecnicos/$tecnicoId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(datos),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar técnico');
    }
  }
}