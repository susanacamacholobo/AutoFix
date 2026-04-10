import 'dart:convert';
import 'package:http/http.dart' as http;

class VehiculosService {
  final String baseUrl = 'http://10.0.2.2:8000';

  Future<List<dynamic>> listarMisVehiculos(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/vehiculos/mis-vehiculos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar vehículos');
    }
  }

  Future<Map<String, dynamic>> crearVehiculo(String token, Map<String, dynamic> vehiculo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/vehiculos/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(vehiculo),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear vehículo');
    }
  }

  Future<void> eliminarVehiculo(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/vehiculos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar vehículo');
    }
  }
}