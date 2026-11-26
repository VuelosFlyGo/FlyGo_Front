import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aerotech_reservas_app/config/api_config.dart';
import 'package:aerotech_reservas_app/services/auth_service.dart';
import 'package:aerotech_reservas_app/services/session_service.dart';

String tokenConExpiracion(DateTime expiracion) {
  String parte(Map<String, dynamic> contenido) =>
      base64Url.encode(utf8.encode(jsonEncode(contenido))).replaceAll('=', '');
  return '${parte({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${parte({'exp': expiracion.millisecondsSinceEpoch ~/ 1000})}.firma';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionService.limpiar();
  });

  tearDown(() => SessionService.limpiar());

  test('restaura una sesión vigente después de recargar', () async {
    final token = tokenConExpiracion(
      DateTime.now().toUtc().add(const Duration(hours: 1)),
    );
    await SessionService.guardar(
      token,
      'cliente',
      usuario: 'luis',
      nombreCompleto: 'Luis Alvares',
    );
    ApiConfig.token = '';
    ApiConfig.rol = 'cliente';
    ApiConfig.usuario = '';
    ApiConfig.nombreCompleto = '';

    expect(await SessionService.restaurar(), isTrue);
    expect(ApiConfig.token, token);
    expect(ApiConfig.rol, 'cliente');
    expect(ApiConfig.usuario, 'luis');
    expect(ApiConfig.nombreCompleto, 'Luis Alvares');
  });

  test('rechaza y elimina una sesión expirada', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'flygo_jwt',
      tokenConExpiracion(
        DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      ),
    );
    await prefs.setString('flygo_rol', 'admin');

    expect(await SessionService.restaurar(), isFalse);
    expect(ApiConfig.token, isEmpty);
    expect(prefs.getString('flygo_jwt'), isNull);
  });

  test('cierra al vencer el token sin esperar una petición', () async {
    final siguiente = SessionService.sesionExpirada.value + 1;
    await SessionService.guardar(
      tokenConExpiracion(DateTime.now().add(const Duration(seconds: 2))),
      'cliente',
      usuario: 'luis',
      nombreCompleto: 'Luis Alvares',
    );

    await Future<void>.delayed(const Duration(seconds: 2));
    expect(ApiConfig.token, isEmpty);
    expect(SessionService.sesionExpirada.value, siguiente);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('flygo_jwt'), isNull);
  });

  test('un cierre recibido invalida la sesión local una sola vez', () async {
    final siguiente = SessionService.sesionCerrada.value + 1;
    await SessionService.guardar(
      tokenConExpiracion(DateTime.now().add(const Duration(minutes: 3))),
      'admin',
      usuario: 'admin',
      nombreCompleto: 'Administrador',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('flygo_jwt');

    await Future.wait([
      SessionService.verificarSesion(),
      SessionService.verificarSesion(),
    ]);

    expect(ApiConfig.token, isEmpty);
    expect(ApiConfig.rol, 'cliente');
    expect(SessionService.sesionCerrada.value, siguiente);
  });

  test('la expiración de una pestaña no borra un token nuevo', () async {
    final ahora = DateTime.now();
    final tokenNuevo = tokenConExpiracion(ahora.add(const Duration(hours: 1)));
    await SessionService.guardar(
      tokenConExpiracion(ahora.add(const Duration(minutes: 3))),
      'cliente',
      usuario: 'luis',
      nombreCompleto: 'Luis Alvares',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flygo_jwt', tokenNuevo);
    try {
      await SessionService.expirar();
      expect(ApiConfig.token, isEmpty);
      expect(prefs.getString('flygo_jwt'), tokenNuevo);
    } finally {
      await prefs.remove('flygo_jwt');
    }
  });

  test('dos tokens de la misma cuenta permiten cerrar ambas pestañas',
      () async {
    final ahora = DateTime.now();
    final tokenInicial =
        tokenConExpiracion(ahora.add(const Duration(minutes: 3)));
    final tokenDeOtraPestana =
        tokenConExpiracion(ahora.add(const Duration(minutes: 4)));
    await SessionService.guardar(
      tokenInicial,
      'cliente',
      usuario: 'luis',
      nombreCompleto: 'Luis Alvares',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flygo_jwt', tokenDeOtraPestana);

    await SessionService.verificarSesion();
    expect(ApiConfig.token, tokenInicial);

    await SessionService.cerrar(todasLasPestanas: true);
    expect(ApiConfig.token, isEmpty);
    expect(prefs.getString('flygo_jwt'), isNull);
  });

  test('la pestaña se cierra cuando Flask revoca su token', () async {
    final siguiente = SessionService.sesionCerrada.value + 1;
    final token =
        tokenConExpiracion(DateTime.now().add(const Duration(minutes: 3)));
    await SessionService.guardar(
      token,
      'cliente',
      usuario: 'luis',
      nombreCompleto: 'Luis Alvares',
    );
    await http.runWithClient(
      AuthService().comprobarSesion,
      () => MockClient((request) async {
        expect(request.url.path, '/api/auth/session');
        expect(request.headers['Authorization'], 'Bearer $token');
        return http.Response('', 401);
      }),
    );
    expect(ApiConfig.token, isEmpty);
    expect(SessionService.sesionCerrada.value, siguiente);
  });

  test('muestra vencimiento cuando Flask aplica un límite más corto', () async {
    final siguiente = SessionService.sesionExpirada.value + 1;
    final token =
        tokenConExpiracion(DateTime.now().add(const Duration(hours: 2)));
    await SessionService.guardar(
      token,
      'cliente',
      usuario: 'luis',
      nombreCompleto: 'Luis Alvares',
    );
    await http.runWithClient(
      AuthService().comprobarSesion,
      () => MockClient(
        (_) async => http.Response('{"codigo":"SESION_EXPIRADA"}', 401),
      ),
    );
    expect(ApiConfig.token, isEmpty);
    expect(SessionService.sesionExpirada.value, siguiente);
  });
}
