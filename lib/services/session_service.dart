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

class TarifaActualizadaException implements Exception {
  const TarifaActualizadaException();
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
  static final ValueNotifier<int> sesionCerrada = ValueNotifier<int>(0);

  static Stream<void> get cambiosEnOtraPestana =>
      SessionStorage.cambios(_tokenKey);
  static Stream<void> get reactivaciones => SessionStorage.reactivaciones;

  static Future<void> verificarSesion() async {
    final token = ApiConfig.token;
    if (token.isEmpty) return;
    if (_estaExpirado(token)) {
      await expirar();
      return;
    }
    final tokenGuardado = await SessionStorage.leer(_tokenKey);
    if (tokenGuardado == token) return;
    final mismoUsuario = tokenGuardado != null &&
        !_estaExpirado(tokenGuardado) &&
        await SessionStorage.leer(_usuarioKey) == ApiConfig.usuario;
    if (ApiConfig.token == token && !mismoUsuario) {
      _limpiarMemoria();
      sesionCerrada.value++;
    }
  }

  static Future<void> guardar(
    String token,
    String rol, {
    required String usuario,
    required String nombreCompleto,
  }) async {
    if (_estaExpirado(token)) throw const SesionExpiradaException();
    await SessionStorage.escribir(_rolKey, rol);
    await SessionStorage.escribir(_usuarioKey, usuario);
    await SessionStorage.escribir(_nombreKey, nombreCompleto);
    await SessionStorage.escribir(_tokenKey, token);
    ApiConfig.token = token;
    ApiConfig.rol = rol;
    ApiConfig.usuario = usuario;
    ApiConfig.nombreCompleto = nombreCompleto;
    _programarExpiracion(token);
  }

  static Future<bool> restaurar() async {
    final token = await SessionStorage.leer(_tokenKey) ?? '';
    final rol = await SessionStorage.leer(_rolKey) ?? 'cliente';
    final usuario = await SessionStorage.leer(_usuarioKey) ?? '';
    final nombreCompleto = await SessionStorage.leer(_nombreKey) ?? '';
    if (token.isEmpty || _estaExpirado(token)) {
      await limpiar();
      if (token.isNotEmpty) sesionExpirada.value++;
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
    final limpieza = limpiar();
    sesionExpirada.value++;
    await limpieza;
  }

  static Future<void> cerrar({bool todasLasPestanas = false}) async {
    final token = ApiConfig.token;
    if (token.isEmpty) return;
    final usuario = ApiConfig.usuario;
    _limpiarMemoria();
    final limpieza = _limpiarAlmacenamiento(
      token,
      usuario: todasLasPestanas && usuario.isNotEmpty ? usuario : null,
    );
    sesionCerrada.value++;
    await limpieza;
  }

  static Future<void> limpiar() async {
    final token = ApiConfig.token;
    _limpiarMemoria();
    await _limpiarAlmacenamiento(token);
  }

  static void _limpiarMemoria() {
    _temporizadorExpiracion?.cancel();
    _temporizadorExpiracion = null;
    ApiConfig.token = '';
    ApiConfig.rol = 'cliente';
    ApiConfig.usuario = '';
    ApiConfig.nombreCompleto = '';
  }

  static Future<void> _limpiarAlmacenamiento(
    String token, {
    String? usuario,
  }) async {
    final mismoUsuario =
        usuario != null && await SessionStorage.leer(_usuarioKey) == usuario;
    final guardado = await SessionStorage.leer(_tokenKey);
    if (ApiConfig.token.isNotEmpty ||
        (guardado != null &&
            guardado != token &&
            !mismoUsuario &&
            !_estaExpirado(guardado))) {
      return;
    }
    await Future.wait([
      SessionStorage.eliminar(_tokenKey),
      SessionStorage.eliminar(_rolKey),
      SessionStorage.eliminar(_usuarioKey),
      SessionStorage.eliminar(_nombreKey),
    ]);
  }

  static bool _estaExpirado(String token) {
    final expiracion = _expiracion(token);
    return expiracion == null || !expiracion.isAfter(DateTime.now().toUtc());
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
