import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'session_service.dart';

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
      await SessionService.expirar();
      throw const SesionExpiradaException();
    }

    throw Exception(_mensajeError(response.body, "No se pudo crear el vuelo."));
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
    required int cantidadAsientos,
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
        "cantidad_asientos": cantidadAsientos,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      await SessionService.expirar();
      throw const SesionExpiradaException();
    }

    if (response.statusCode == 409) {
      throw const ConflictoConcurrenciaException(
        "La capacidad o disponibilidad cambió mientras editaba el vuelo. Actualizamos el panel; revise los datos y vuelva a intentarlo.",
      );
    }

    throw Exception(
      _mensajeError(response.body, "No se pudo actualizar el vuelo."),
    );
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
      await SessionService.expirar();
      throw const SesionExpiradaException();
    }

    if (response.statusCode == 409) {
      throw const ConflictoConcurrenciaException(
        "El vuelo cambió mientras intentaba desactivarlo. La lista fue actualizada; revise su estado antes de volver a intentarlo.",
      );
    }

    try {
      final body = jsonDecode(response.body);
      final errorMsg =
          body["detalle"] ?? body["error"] ?? "No se pudo desactivar el vuelo";
      throw Exception(errorMsg);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception("Error del servidor: ${response.statusCode}");
    }
  }

  String _mensajeError(String body, String fallback) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data["detalle"]?.toString() ??
          data["error"]?.toString() ??
          fallback;
    } catch (_) {
      return fallback;
    }
  }
}
