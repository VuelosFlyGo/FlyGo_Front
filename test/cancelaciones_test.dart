import 'package:aerotech_reservas_app/config/api_config.dart';
import 'package:aerotech_reservas_app/models/reserva.dart';
import 'package:aerotech_reservas_app/models/vuelo.dart';
import 'package:aerotech_reservas_app/widgets/reserva_card.dart';
import 'package:aerotech_reservas_app/widgets/vuelo_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Reserva reserva({String fecha = '2027-06-20', bool? permiso}) => Reserva(
      id: 1,
      vueloId: 1,
      codigoReserva: 'FG-TEST',
      cantidadAsientos: 1,
      total: 80,
      precioActual: 80,
      estado: 'ACTIVA',
      fechaReserva: '2026-11-26',
      aerolinea: 'FlyGo',
      origen: 'Quito',
      destino: 'Cuenca',
      fechaVuelo: fecha,
      horaSalida: '10:00:00',
      horaLlegada: '11:00:00',
      asientos: ['1A'],
      modificada: false,
      cancelacionPermitida: permiso,
    );

void main() {
  test('la cancelación requiere al menos 24 horas exactas en Ecuador', () {
    final limite = DateTime.utc(2027, 6, 19, 15);
    expect(reserva().permiteCancelarEn(limite), isTrue);
    expect(
        reserva()
            .permiteCancelarEn(limite.subtract(const Duration(seconds: 1))),
        isTrue);
    expect(reserva().permiteCancelarEn(limite.add(const Duration(seconds: 1))),
        isFalse);
    expect(reserva(permiso: false).permiteCancelarEn(limite), isFalse);
  });
  testWidgets('cliente ve el bloqueo y no puede cancelar pasado el plazo',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
      child: ReservaCard(
          reserva: reserva(fecha: '2020-01-01'),
          onCancelar: () => fail('No debe cancelar')),
    ))));
    final boton =
        tester.widget<TextButton>(find.widgetWithText(TextButton, 'Cancelar'));
    expect(boton.onPressed, isNull);
    expect(find.textContaining('mínimo de 24 horas'), findsOneWidget);
  });
  for (final cantidad in [0, 2]) {
    testWidgets('administrador con $cantidad reservas activas', (tester) async {
      ApiConfig.rol = 'admin';
      addTearDown(() => ApiConfig.rol = 'cliente');
      final vuelo = Vuelo(
          id: 1,
          aerolinea: 'FlyGo',
          origen: 'Quito',
          destino: 'Cuenca',
          fecha: '2027-06-20',
          horaSalida: '10:00',
          horaLlegada: '11:00',
          precio: 80,
          asientosDisponibles: 8,
          totalAsientos: 10,
          reservasActivas: cantidad);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
        child: VueloCard(
            vuelo: vuelo,
            onReservar: () {},
            onEditar: () {},
            onEliminar: () {}),
      ))));
      final boton = tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Desactivar'));
      expect(boton.onPressed == null, cantidad > 0);
      expect(find.textContaining('reservas activas'),
          cantidad > 0 ? findsOneWidget : findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
