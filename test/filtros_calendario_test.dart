import 'dart:convert';

import 'package:aerotech_reservas_app/config/api_config.dart';
import 'package:aerotech_reservas_app/pages/vuelos_page.dart';
import 'package:aerotech_reservas_app/theme/aerotech_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

String iso(DateTime fecha) => fecha.toIso8601String().substring(0, 10);

void main() {
  for (final rol in ['cliente', 'admin']) {
    testWidgets('control de los filtros de calendario para $rol',
        (tester) async {
      final ahora = DateTime.now().toUtc().subtract(const Duration(hours: 5));
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);
      final anterior = DateTime(hoy.year, hoy.month, hoy.day - 7);
      final manana = DateTime(hoy.year, hoy.month, hoy.day + 1);
      final pasado = DateTime(hoy.year, hoy.month, hoy.day - 1);
      final maximo = DateTime(hoy.year, hoy.month, hoy.day + 730);
      final minimo = rol == 'admin' ? anterior : hoy;
      ApiConfig.rol = rol;
      addTearDown(() => ApiConfig.rol = 'cliente');
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await http.runWithClient(() async {
        await tester.pumpWidget(
            MaterialApp(theme: AeroTechTheme.light, home: const VuelosPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextField, 'Salida desde'));
        await tester.pumpAndSettle();
        var dialogo =
            tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
        expect(dialogo.firstDate, minimo);
        expect(dialogo.lastDate, maximo);

        await tester.tap(find.byTooltip('Switch to input'));
        await tester.pumpAndSettle();
        final campo = find.descendant(
            of: find.byType(DatePickerDialog),
            matching: find.byType(TextField));
        final fechaInvalida = rol == 'cliente'
            ? pasado
            : DateTime(hoy.year, hoy.month, hoy.day + 731);
        String formato(DateTime fecha) =>
            '${fecha.month}/${fecha.day}/${fecha.year}';
        await tester.enterText(campo, formato(fechaInvalida));
        await tester.tap(find.text('Aceptar'));
        await tester.pumpAndSettle();
        expect(find.text('La fecha está fuera del rango permitido.'),
            findsOneWidget);

        await tester.enterText(campo, formato(manana));
        await tester.tap(find.text('Aceptar'));
        await tester.pumpAndSettle();
        expect(find.byType(DatePickerDialog), findsNothing);

        await tester.tap(find.widgetWithText(TextField, 'Salida hasta'));
        await tester.pumpAndSettle();
        dialogo =
            tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
        expect(dialogo.firstDate, manana);
        expect(dialogo.lastDate, maximo);
        await tester.tap(find.byTooltip('Switch to input'));
        await tester.pumpAndSettle();
        await tester.enterText(campo, formato(hoy));
        await tester.tap(find.text('Aceptar'));
        await tester.pumpAndSettle();
        expect(find.text('La fecha está fuera del rango permitido.'),
            findsOneWidget);
        await tester.enterText(campo, formato(manana));
        await tester.tap(find.text('Aceptar'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextField, 'Salida desde'));
        await tester.pumpAndSettle();
        dialogo =
            tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
        expect(dialogo.lastDate, manana);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
          () => MockClient((_) async => http.Response(
              jsonEncode([
                {
                  'id': 1,
                  'aerolinea': 'FlyGo',
                  'origen': 'Quito',
                  'destino': 'Cuenca',
                  'fecha': iso(rol == 'admin' ? anterior : manana),
                  'hora_salida': '08:00:00',
                  'hora_llegada': '09:00:00',
                  'precio': 80,
                  'asientos_disponibles': 10,
                  'total_asientos': 10,
                }
              ]),
              200)));
    });
  }
}
