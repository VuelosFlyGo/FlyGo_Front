import 'dart:convert';

import 'package:aerotech_reservas_app/models/vuelo.dart';
import 'package:aerotech_reservas_app/pages/crear_vuelo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final ahora = DateTime.now().toUtc().subtract(const Duration(hours: 5));
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  final limite = DateTime(hoy.year, hoy.month, hoy.day + 730);

  for (final fechaAnterior in [null, '2020-01-01', '2099-01-01']) {
    testWidgets('el calendario controla el rango para $fechaAnterior',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await http.runWithClient(() async {
        await tester.pumpWidget(MaterialApp(
          home: CrearVueloPage(
            vuelo: fechaAnterior == null
                ? null
                : Vuelo(
                    id: 1,
                    aerolinea: 'FlyGo',
                    origen: 'Quito',
                    destino: 'Cuenca',
                    fecha: fechaAnterior,
                    horaSalida: '08:00:00',
                    horaLlegada: '09:00:00',
                    precio: 80,
                    asientosDisponibles: 12,
                  ),
          ),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Fecha del Vuelo'));
        await tester.pumpAndSettle();
        final calendario =
            tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
        expect(calendario.firstDate, hoy);
        expect(calendario.lastDate, limite);
        expect(
            calendario.initialDate,
            fechaAnterior == '2020-01-01'
                ? hoy
                : fechaAnterior == '2099-01-01'
                    ? limite
                    : DateTime(hoy.year, hoy.month, hoy.day + 1));
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
      },
          () => MockClient((_) async => http.Response(
              jsonEncode([
                {
                  'id': 1,
                  'modelo': 'ATR 72',
                  'asientos_ejecutiva': 8,
                  'asientos_turista': 56
                },
              ]),
              200)));
    });
  }
}
