import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/usuario_registro.dart';

class AuthService {
  Future<void> registrar(UsuarioRegistro usuario) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/usuarios/registro");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(usuario.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception(response.body);
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/auth/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
      ApiConfig.token = loginResponse.token;
      ApiConfig.rol = loginResponse.rol;
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
      ApiConfig.token = "";
      ApiConfig.rol = "cliente";
    }
  }
}
