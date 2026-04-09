import 'dart:convert';
import 'package:http/http.dart' as http;

class RolesService {
  final String baseUrl = 'http://10.0.2.2:8000';

  Future<List<dynamic>> listarRoles(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/roles/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar roles');
    }
  }

  Future<Map<String, dynamic>> crearRol(String token, String nombre, String descripcion) async {
    final response = await http.post(
      Uri.parse('$baseUrl/roles/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nombre': nombre, 'descripcion': descripcion}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear rol');
    }
  }

  Future<Map<String, dynamic>> actualizarRol(String token, int id, Map<String, dynamic> datos) async {
    final response = await http.put(
      Uri.parse('$baseUrl/roles/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(datos),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar rol');
    }
  }
}