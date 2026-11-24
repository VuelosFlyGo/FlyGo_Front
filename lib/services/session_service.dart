import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'session_storage.dart';

class SesionExpiradaException implements Exception {
  const SesionExpiradaException();

  @override
  String toString() => 'La sesión expiró. Inicie sesión nuevamente.';
}

class ConflictoConcurrenciaException implements Exception {
  final String mensaje;

  const ConflictoConcurrenciaException(this.mensaje);

  @override
  String toString() => mensaje;
}

class ReservaActualizadaEnOtraPestanaException implements Exception {
  const ReservaActualizadaEnOtraPestanaException();

  @override
  String toString() =>
      'Esta reserva ya fue modificada y confirmada en otra pestaña.';
}

class SessionService {
  static const _tokenKey = 'flygo_jwt';
  static const _rolKey = 'flygo_rol';
  static const _usuarioKey = 'flygo_usuario';
  static const _nombreKey = 'flygo_nombre_completo';
  static Timer? _temporizadorExpiracion;

  static final ValueNotifier<int> sesionExpirada = ValueNotifier<int>(0);

  static Future<void> guardar(
    String token,
    String rol, {
    required String usuario,
    required String nombreCompleto,
  }) async {
    ApiConfig.token = token;
    ApiConfig.rol = rol;
    ApiConfig.usuario = usuario;
    ApiConfig.nombreCompleto = nombreCompleto;
    await SessionStorage.escribir(_tokenKey, token);
    await SessionStorage.escribir(_rolKey, rol);
    await SessionStorage.escribir(_usuarioKey, usuario);
    await SessionStorage.escribir(_nombreKey, nombreCompleto);
    _programarExpiracion(token);
  }

  static Future<bool> restaurar() async {
    final token = await SessionStorage.leer(_tokenKey) ?? '';
    final rol = await SessionStorage.leer(_rolKey) ?? 'cliente';
    final usuario = await SessionStorage.leer(_usuarioKey) ?? '';
    final nombreCompleto = await SessionStorage.leer(_nombreKey) ?? '';
    if (token.isEmpty || _estaExpirado(token)) {
      await limpiar();
      return false;
    }
    ApiConfig.token = token;
    ApiConfig.rol = rol;
    ApiConfig.usuario = usuario;
    ApiConfig.nombreCompleto = nombreCompleto;
    _programarExpiracion(token);
    return true;
  }

  static Future<void> expirar() async {
    if (ApiConfig.token.isEmpty) return;
    await limpiar();
    sesionExpirada.value++;
  }

  static Future<void> limpiar() async {
    _temporizadorExpiracion?.cancel();
    _temporizadorExpiracion = null;
    ApiConfig.token = '';
    ApiConfig.rol = 'cliente';
    ApiConfig.usuario = '';
    ApiConfig.nombreCompleto = '';
    await SessionStorage.eliminar(_tokenKey);
    await SessionStorage.eliminar(_rolKey);
    await SessionStorage.eliminar(_usuarioKey);
    await SessionStorage.eliminar(_nombreKey);
  }

  static bool _estaExpirado(String token) {
    final expiracion = _expiracion(token);
    return expiracion == null ||
        !expiracion
            .isAfter(DateTime.now().toUtc().add(const Duration(seconds: 2)));
  }

  static void _programarExpiracion(String token) {
    _temporizadorExpiracion?.cancel();
    final expiracion = _expiracion(token);
    if (expiracion == null) {
      unawaited(expirar());
      return;
    }
    final restante = expiracion.difference(DateTime.now().toUtc());
    if (restante <= Duration.zero) {
      unawaited(expirar());
      return;
    }
    _temporizadorExpiracion = Timer(restante, () => unawaited(expirar()));
  }

  static DateTime? _expiracion(String token) {
    try {
      final partes = token.split('.');
      if (partes.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(partes[1]))),
      ) as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
    } catch (_) {
      return null;
    }
  }
}
