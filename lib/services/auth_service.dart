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

  Future<void> comprobarSesion() async {
    final token = ApiConfig.token;
    if (token.isEmpty) return;
    final url = Uri.parse("${ApiConfig.baseUrl}/api/auth/session");
    late http.Response respuesta;
    try {
      respuesta = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 5));
    } catch (_) {
      return;
    }
    if (respuesta.statusCode == 401 && ApiConfig.token == token) {
      try {
        final error = jsonDecode(respuesta.body);
        if (error is Map && error['codigo'] == 'SESION_EXPIRADA') {
          await SessionService.expirar();
          return;
        }
      } on FormatException {
        // Una respuesta anterior de la API puede no incluir el código.
      }
      await SessionService.verificarSesion();
      if (ApiConfig.token == token) await SessionService.cerrar();
    }
  }

  Future<void> logout() async {
    final token = ApiConfig.token;
    if (token.isEmpty) return;
    await SessionService.cerrar(todasLasPestanas: true);
    final url = Uri.parse("${ApiConfig.baseUrl}/api/auth/logout");
    try {
      await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      ).timeout(const Duration(seconds: 5));
    } catch (_) {
      // El cierre local ya se propagó a las demás pestañas.
    }
  }
}
