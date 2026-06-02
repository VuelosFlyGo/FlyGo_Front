import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/vuelo.dart';

class VuelosService {
  Future<List<Vuelo>> buscarVuelos({String? origen, String? destino, String? fecha}) async {
    final params = <String, String>{};
    if (origen != null && origen.isNotEmpty) params["origen"] = origen;
    if (destino != null && destino.isNotEmpty) params["destino"] = destino;
    if (fecha != null && fecha.isNotEmpty) params["fecha"] = fecha;

    final uri = Uri.parse("${ApiConfig.baseUrl}/api/vuelos").replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer ${ApiConfig.token}"},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Vuelo.fromJson(e)).toList();
    }

    if (response.statusCode == 401) {
      throw Exception("Sesión expirada o token inválido");
    }

    throw Exception("No se pudieron obtener los vuelos");
  }
}
