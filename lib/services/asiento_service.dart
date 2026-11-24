import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/asiento.dart';
import 'session_service.dart';

class AsientoService {
  Future<List<Asiento>> listarAsientos(int vueloId) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/vuelos/$vueloId/asientos");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer ${ApiConfig.token}",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Asiento.fromJson(item)).toList();
    }

    if (response.statusCode == 401) {
      await SessionService.expirar();
      throw const SesionExpiradaException();
    }

    throw Exception(response.body);
  }

  Future<Map<String, dynamic>> reservarAsientos({
    required int vueloId,
    required List<String> asientos,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/reservas/asientos");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiConfig.token}",
      },
      body: jsonEncode({
        "vuelo_id": vueloId,
        "asientos": asientos,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      await SessionService.expirar();
      throw const SesionExpiradaException();
    }

    if (response.statusCode == 409) {
      throw const ConflictoConcurrenciaException(
        "Otro cliente reservó uno de esos asientos al mismo tiempo. Actualizamos el mapa; revise los asientos disponibles y seleccione otro.",
      );
    }

    throw Exception(response.body);
  }
}
