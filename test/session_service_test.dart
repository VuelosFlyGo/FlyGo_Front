import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aerotech_reservas_app/config/api_config.dart';
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
}
