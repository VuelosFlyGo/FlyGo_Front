import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/usuario_registro.dart';
import 'session_service.dart';
import 'servidor_no_disponible_exception.dart';

class AuthService {
  Future<void> registrar(UsuarioRegistro usuario) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/usuarios/registro");
    late http.Response response;
    try {
      response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(usuario.toJson()),
      );
    } on http.ClientException {
      throw Exception(
        "No se pudo conectar con el servidor. Verifique que la API de FlyGo esté encendida.",
      );
    }

    if (response.statusCode != 201) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(
          data["error"]?.toString() ?? "No se pudo crear la cuenta.",
        );
      } on FormatException {
        throw Exception("No se pudo crear la cuenta. Inténtelo nuevamente.");
      }
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/auth/login");
    late http.Response response;
    try {
      response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );
    } on http.ClientException {
      throw const ServidorNoDisponibleException();
    }

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
      await SessionService.guardar(
        loginResponse.token,
        loginResponse.rol,
        usuario: loginResponse.usuario,
        nombreCompleto: loginResponse.nombreCompleto,
      );
      return loginResponse;
    }

    throw Exception("Usuario o contraseña incorrectos");
  }

  Future<void> logout() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/auth/logout");
    try {
      await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiConfig.token}"
        },
      );
    } catch (_) {
      // Ignore network errors to ensure local logout still completes
    } finally {
      await SessionService.limpiar();
    }
  }
}
