import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/vuelo.dart';
import 'session_service.dart';
import 'servidor_no_disponible_exception.dart';

class VuelosService {
  Future<List<Vuelo>> buscarVuelos({
    String? origen,
    String? destino,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    final params = <String, String>{};
    if (origen != null && origen.isNotEmpty) params["origen"] = origen;
    if (destino != null && destino.isNotEmpty) params["destino"] = destino;
    if (fechaInicio != null && fechaInicio.isNotEmpty)
      params["fecha_inicio"] = fechaInicio;
    if (fechaFin != null && fechaFin.isNotEmpty) params["fecha_fin"] = fechaFin;

    final uri = Uri.parse("${ApiConfig.baseUrl}/api/vuelos")
        .replace(queryParameters: params);

    late http.Response response;
    try {
      response = await http.get(
        uri,
        headers: {"Authorization": "Bearer ${ApiConfig.token}"},
      );
    } on http.ClientException {
      throw const ServidorNoDisponibleException();
    }

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Vuelo.fromJson(e)).toList();
    }

    if (response.statusCode == 401) {
      await SessionService.expirar();
      throw const SesionExpiradaException();
    }

    throw Exception("No se pudieron obtener los vuelos");
  }
}
