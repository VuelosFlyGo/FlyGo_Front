import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/reserva.dart';
import 'session_service.dart';

class ReservasService {
  Future<void> crearReserva(int vueloId, int cantidadAsientos) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/reservas");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiConfig.token}",
      },
      body: jsonEncode({
        "vuelo_id": vueloId,
        "cantidad_asientos": cantidadAsientos,
      }),
    );

    if (response.statusCode != 201) {
      if (response.statusCode == 401) {
        await SessionService.expirar();
        throw const SesionExpiradaException();
      }
      if (response.statusCode == 409) {
        throw const ConflictoConcurrenciaException(
          "Otro cliente reservó los últimos cupos al mismo tiempo. Actualizamos la disponibilidad del vuelo; elija otra opción.",
        );
      }
      final mensaje = _obtenerMensajeError(response.body);

      throw Exception(mensaje);
    }
  }

  Future<List<Reserva>> listarMisReservas() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/reservas/mis-reservas");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer ${ApiConfig.token}",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Reserva.fromJson(e)).toList();
    }

    if (response.statusCode == 401) {
      await SessionService.expirar();
      throw const SesionExpiradaException();
    }
    throw Exception("No se pudieron cargar las reservas");
  }

  Future<void> cancelarReserva(int reservaId) async {
    final url =
        Uri.parse("${ApiConfig.baseUrl}/api/reservas/$reservaId/cancelar");

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer ${ApiConfig.token}",
      },
    );

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        await SessionService.expirar();
        throw const SesionExpiradaException();
      }
      if (response.statusCode == 409) {
        throw const ConflictoConcurrenciaException(
          "La reserva cambió mientras intentaba cancelarla. Actualizamos su estado; revíselo antes de volver a intentarlo.",
        );
      }
      final mensaje = _obtenerMensajeError(response.body);

      throw Exception(mensaje);
    }
  }

  Future<void> actualizarReservaAsientos(
      int reservaId, List<String> asientos) async {
    final url =
        Uri.parse("${ApiConfig.baseUrl}/api/reservas/$reservaId/asientos");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiConfig.token}",
      },
      body: jsonEncode({
        "asientos": asientos,
      }),
    );

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        await SessionService.expirar();
        throw const SesionExpiradaException();
      }
      if (response.statusCode == 409) {
        final mensaje = _obtenerMensajeError(response.body);
        if (mensaje.contains("ya fue modificada") ||
            mensaje.contains("nuevos cambios")) {
          throw const ReservaActualizadaEnOtraPestanaException();
        }
        throw const ConflictoConcurrenciaException(
          "Otro cliente modificó la disponibilidad mientras confirmaba. Actualizamos los asientos; revise la selección antes de continuar.",
        );
      }
      final mensaje = _obtenerMensajeError(response.body);
      throw Exception(mensaje);
    }
  }

  Future<Uint8List> descargarBoletos(int reservaId) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/api/reservas/$reservaId/boletos.pdf",
    );
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer ${ApiConfig.token}"},
    );
    if (response.statusCode == 200) return response.bodyBytes;
    if (response.statusCode == 401) {
      await SessionService.expirar();
      throw const SesionExpiradaException();
    }
    if (response.statusCode == 404) {
      throw Exception(
        "No se encontró una reserva activa con boletos disponibles.",
      );
    }
    throw Exception(_obtenerMensajeError(response.body));
  }

  Future<Uint8List> descargarFacturaPdf(int reservaId) async {
    return _descargarFactura(reservaId, "pdf");
  }

  Future<Uint8List> descargarFacturaXml(int reservaId) async {
    return _descargarFactura(reservaId, "xml");
  }

  Future<Uint8List> _descargarFactura(int reservaId, String formato) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/api/reservas/$reservaId/factura.$formato",
    );
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer ${ApiConfig.token}"},
    );
    if (response.statusCode == 200) return response.bodyBytes;
    if (response.statusCode == 401) {
      await SessionService.expirar();
      throw const SesionExpiradaException();
    }
    if (response.statusCode == 404) {
      throw Exception("No se encontró una reserva activa para facturar.");
    }
    throw Exception(_obtenerMensajeError(response.body));
  }

  String _obtenerMensajeError(String body) {
    try {
      final data = jsonDecode(body);

      final detalle = data["detalle"]?.toString() ?? "";
      final error = data["error"]?.toString() ?? "";

      if (detalle.contains("ya fue modificada") ||
          detalle.contains("nuevos cambios")) {
        return detalle;
      }

      if (detalle.contains("Uno o más asientos ya no están disponibles") ||
          error.contains("Conflicto de concurrencia") ||
          error.contains("No se pudo registrar la reserva")) {
        return "Otro cliente cambió la disponibilidad al mismo tiempo. Actualizamos los datos; revise los asientos disponibles antes de continuar.";
      }

      if (error.isNotEmpty) {
        return error;
      }

      if (detalle.isNotEmpty) {
        return detalle;
      }

      return "Ocurrió un error al procesar la reserva.";
    } catch (e) {
      if (body.contains("Uno o más asientos ya no están disponibles")) {
        return "Otro cliente cambió la disponibilidad al mismo tiempo. Actualizamos los datos; revise los asientos disponibles antes de continuar.";
      }

      return "Ocurrió un error al procesar la reserva.";
    }
  }
}
