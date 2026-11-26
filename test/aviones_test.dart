import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:aerotech_reservas_app/models/asiento.dart';
import 'package:aerotech_reservas_app/pages/crear_vuelo_page.dart';
import 'package:aerotech_reservas_app/theme/aerotech_theme.dart';
import 'package:aerotech_reservas_app/widgets/cabina_asientos.dart';
import 'package:aerotech_reservas_app/widgets/vista_previa_avion.dart';

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets('selecciona aeronave y consulta capacidad en $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await http.runWithClient(
        () async {
          await tester.pumpWidget(MaterialApp(
            theme: AeroTechTheme.light,
            home: const CrearVueloPage(),
          ));
          await tester.pumpAndSettle();
          final selector = find.byType(DropdownButtonFormField<int>);
          await tester.ensureVisible(selector);
          await tester.pumpAndSettle();
          await tester.tap(selector);
          await tester.pumpAndSettle();
          await tester.tap(find.text('ATR 72 · 64 asientos').last);
          await tester.pumpAndSettle();
          expect(find.text('64 asientos en total'), findsOneWidget);
          expect(find.text('Ejecutiva: 8'), findsOneWidget);
          expect(find.text('Turista: 56'), findsOneWidget);
          expect(find.text('Capacidad total'), findsNothing);
          expect(find.byType(VistaPreviaAvion), findsOneWidget);
          expect(find.text('Vista previa de la cabina'), findsOneWidget);
          expect(
              find.byKey(const ValueKey('preview-seat-16D')), findsOneWidget);
          expect(find.byKey(const ValueKey('preview-seat-17A')), findsNothing);
          expect(find.byTooltip('2D · Ejecutiva'), findsOneWidget);
          expect(find.byTooltip('3A · Turista'), findsOneWidget);
          await tester.ensureVisible(selector);
          await tester.pumpAndSettle();
          await tester.tap(selector);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Embraer E190 · 96 asientos').last);
          await tester.pumpAndSettle();
          expect(find.text('96 asientos en total'), findsOneWidget);
          expect(find.byTooltip('3D · Ejecutiva'), findsOneWidget);
          expect(find.byTooltip('4A · Turista'), findsOneWidget);
          expect(
              find.byKey(const ValueKey('preview-seat-24D')), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
        () => MockClient((request) async {
          expect(request.url.path, '/api/admin/aviones');
          return http.Response(
              jsonEncode([
                {
                  'id': 1,
                  'modelo': 'ATR 72',
                  'asientos_ejecutiva': 8,
                  'asientos_turista': 56,
                },
                {
                  'id': 3,
                  'modelo': 'Embraer E190',
                  'asientos_ejecutiva': 12,
                  'asientos_turista': 84,
                },
              ]),
              200);
        }),
      );
    });

    testWidgets('muestra ambas clases de cabina en $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final asientos = [
        for (var i = 0; i < 12; i++)
          Asiento(
            id: i,
            vueloId: 1,
            numeroAsiento: '${i ~/ 4 + 1}${"ABCD"[i % 4]}',
            estado: 'DISPONIBLE',
            clase: i < 8 ? 'EJECUTIVA' : 'TURISTA',
          ),
      ];
      await tester.pumpWidget(MaterialApp(
        theme: AeroTechTheme.light,
        home: Scaffold(
          body: CabinaAsientos(
            asientos: asientos,
            seleccionados: const [],
            onAsientoTap: (_) {},
          ),
        ),
      ));
      expect(find.text('Clase ejecutiva'), findsOneWidget);
      expect(find.text('Clase turista'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
