import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AdminVueloService {
  Future<Map<String, dynamic>> crearVuelo({
    required String aerolinea,
    required String origen,
    required String destino,
    required String fecha,
    required String horaSalida,
    required String horaLlegada,
    required double precio,
    required int cantidadAsientos,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/vuelos");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiConfig.token}",
      },
      body: jsonEncode({
        "aerolinea": aerolinea,
        "origen": origen,
        "destino": destino,
        "fecha": fecha,
        "hora_salida": horaSalida,
        "hora_llegada": horaLlegada,
        "precio": precio,
        "cantidad_asientos": cantidadAsientos,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception("Sesión expirada o token inválido");
    }

    throw Exception(response.body);
  }

  Future<Map<String, dynamic>> editarVuelo({
    required int id,
    required String aerolinea,
    required String origen,
    required String destino,
    required String fecha,
    required String horaSalida,
    required String horaLlegada,
    required double precio,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/vuelos/$id");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiConfig.token}",
      },
      body: jsonEncode({
        "aerolinea": aerolinea,
        "origen": origen,
        "destino": destino,
        "fecha": fecha,
        "hora_salida": horaSalida,
        "hora_llegada": horaLlegada,
        "precio": precio,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception("Sesión expirada o token inválido");
    }

    throw Exception(response.body);
  }

  Future<void> eliminarVuelo(int id) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/vuelos/$id");

    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer ${ApiConfig.token}",
      },
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw Exception("Sesión expirada o token inválido");
    }

    try {
      final body = jsonDecode(response.body);
      final errorMsg = body["detalle"] ?? body["error"] ?? "No se pudo eliminar el vuelo";
      throw Exception(errorMsg);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception("Error del servidor: ${response.statusCode}");
    }
  }
}