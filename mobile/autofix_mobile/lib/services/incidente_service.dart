import 'dart:convert';
import 'package:http/http.dart' as http;

class IncidenteService {
  final String baseUrl = 'http://10.0.2.2:8000';

  Future<List<dynamic>> listarMisIncidentes(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/incidentes/mis-incidentes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar incidentes');
    }
  }

  Future<Map<String, dynamic>> crearIncidente(String token, Map<String, dynamic> incidente) async {
    final response = await http.post(
      Uri.parse('$baseUrl/incidentes/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(incidente),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear incidente');
    }
  }
}