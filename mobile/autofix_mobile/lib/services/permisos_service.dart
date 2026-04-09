import 'dart:convert';
import 'package:http/http.dart' as http;

class PermisosService {
  final String baseUrl = 'http://10.0.2.2:8000';

  Future<List<dynamic>> listarPermisos(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/permisos/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar permisos');
    }
  }

  Future<List<dynamic>> listarPermisosPorRol(String token, int rolId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/permisos/rol/$rolId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar permisos del rol');
    }
  }

  Future<void> asignarPermiso(String token, int rolId, int permisoId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/permisos/rol/$rolId/asignar/$permisoId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Error al asignar permiso');
    }
  }

  Future<void> removerPermiso(String token, int rolId, int permisoId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/permisos/rol/$rolId/remover/$permisoId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Error al remover permiso');
    }
  }
}