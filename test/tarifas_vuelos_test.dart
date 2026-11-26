import 'dart:convert';

import 'package:aerotech_reservas_app/config/api_config.dart';
import 'package:aerotech_reservas_app/models/vuelo.dart';
import 'package:aerotech_reservas_app/pages/seleccion_asientos_page.dart';
import 'package:aerotech_reservas_app/pages/vuelos_page.dart';
import 'package:aerotech_reservas_app/theme/aerotech_theme.dart';
import 'package:aerotech_reservas_app/widgets/vuelo_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final vuelo = Vuelo(
    id: 1,
    aerolinea: 'FlyGo',
    origen: 'Quito',
    destino: 'Guayaquil',
    fecha: '2027-06-20',
    horaSalida: '08:00:00',
    horaLlegada: '09:30:00',
    precio: 80,
    precioEjecutiva: 140,
    asientosDisponibles: 60,
    totalAsientos: 64,
    ejecutivaDisponibles: 6,
    turistaDisponibles: 54,
    avionModelo: 'ATR 72',
    avionId: 1,
  );

  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    for (final rol in ['cliente', 'admin']) {
      testWidgets('tarjeta de $rol en $size', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        ApiConfig.rol = rol;
        addTearDown(() => ApiConfig.rol = 'cliente');
        await tester.pumpWidget(MaterialApp(
          theme: AeroTechTheme.light,
          home: Scaffold(
              body: SingleChildScrollView(
            child: VueloCard(
                vuelo: vuelo,
                onReservar: () {},
                onEditar: () {},
                onEliminar: () {}),
          )),
        ));
        expect(find.text('1h 30min'), findsOneWidget);
        expect(find.text('Turista · \$80.00'), findsOneWidget);
        expect(find.text('Ejecutiva · \$140.00'), findsOneWidget);
        expect(find.text('6 disponibles'), findsOneWidget);
        expect(find.text('54 disponibles'), findsOneWidget);
        expect(find.text(rol == 'admin' ? 'Ocupación' : 'Seleccionar asientos'),
            findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('el total de dos clases se envía al confirmar', (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Map<String, dynamic>? solicitud;
    await http.runWithClient(() async {
      await tester.pumpWidget(MaterialApp(
        theme: AeroTechTheme.light,
        home: Builder(
            builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SeleccionAsientosPage(vuelo: vuelo),
                        )),
                    child: const Text('Abrir'),
                  ),
                )),
      ));
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2A'));
      await tester.pumpAndSettle();
      expect(find.text('\$220.00'), findsOneWidget);
      await tester.tap(find.text('Confirmar reserva'));
      await tester.pumpAndSettle();
      expect(solicitud?['total_esperado'], 220);
      expect(solicitud?['asientos'], ['1A', '2A']);
      await tester.pumpWidget(const SizedBox.shrink());
    },
        () => MockClient((request) async {
              if (request.method == 'GET') {
                return http.Response(
                    jsonEncode([
                      {
                        'id': 1,
                        'vuelo_id': 1,
                        'numero_asiento': '1A',
                        'estado': 'DISPONIBLE',
                        'clase': 'EJECUTIVA',
                        'precio': 140
                      },
                      {
                        'id': 2,
                        'vuelo_id': 1,
                        'numero_asiento': '2A',
                        'estado': 'DISPONIBLE',
                        'clase': 'TURISTA',
                        'precio': 80
                      },
                    ]),
                    200);
              }
              solicitud = jsonDecode(request.body) as Map<String, dynamic>;
              return http.Response(
                  jsonEncode({
                    'reserva': {'codigo_reserva': 'FG-TEST'}
                  }),
                  201);
            }));
  });

  testWidgets('ordena los vuelos por precio', (tester) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Map<String, dynamic> registro(int id, String nombre, double precio) => {
          'id': id,
          'aerolinea': nombre,
          'origen': 'Quito',
          'destino': 'Cuenca',
          'fecha': '2027-06-20',
          'hora_salida': '08:00:00',
          'hora_llegada': '09:00:00',
          'precio': precio,
          'asientos_disponibles': 10,
          'total_asientos': 10,
        };
    await http.runWithClient(() async {
      await tester.pumpWidget(MaterialApp(
        theme: AeroTechTheme.light,
        home: const VuelosPage(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Ordenar vuelos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Precio').last);
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Vuelo económico')).dy,
          lessThan(tester.getTopLeft(find.text('Vuelo costoso')).dy));
      await tester.pumpWidget(const SizedBox.shrink());
    },
        () => MockClient((_) async => http.Response(
            jsonEncode([
              registro(1, 'Vuelo costoso', 180),
              registro(2, 'Vuelo económico', 80),
            ]),
            200)));
  });
}
