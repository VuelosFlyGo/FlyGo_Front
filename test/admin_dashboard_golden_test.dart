import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aerotech_reservas_app/models/admin_dashboard.dart';
import 'package:aerotech_reservas_app/pages/admin_dashboard_page.dart';
import 'package:aerotech_reservas_app/theme/aerotech_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const data = AdminDashboardData(
    resumen: AdminResumen(
      vuelosVigentes: 13,
      vuelosFinalizados: 1,
      vuelosInactivos: 2,
      asientosDisponibles: 155,
      reservasActivas: 8,
      pasajerosConfirmados: 21,
      ingresosConfirmados: 1805,
      clientesActivos: 3,
    ),
    proximosVuelos: [
      AdminVueloResumen(
        id: 14,
        aerolinea: 'FlyGo Sync',
        origen: 'Quito',
        destino: 'Manta',
        fecha: '2027-02-27',
        horaSalida: '14:00:00',
        horaLlegada: '15:00:00',
        precio: 80,
        asientosDisponibles: 10,
      ),
      AdminVueloResumen(
        id: 15,
        aerolinea: 'AeroAndes',
        origen: 'Ecuador',
        destino: 'Chile',
        fecha: '2027-06-20',
        horaSalida: '02:00:00',
        horaLlegada: '05:00:00',
        precio: 85,
        asientosDisponibles: 16,
      ),
    ],
    auditoria: [
      AdminVueloAuditoria(
        id: 8,
        aerolinea: 'FlyGo Test',
        origen: 'Ambato',
        destino: 'Cuenca',
        fecha: '2027-01-15',
        horaSalida: '10:00:00',
        horaLlegada: '11:00:00',
        precio: 75,
        asientosDisponibles: 8,
        fechaDesactivacion: '2026-11-24T15:30:00-05:00',
        reservasRelacionadas: 0,
      ),
      AdminVueloAuditoria(
        id: 4,
        aerolinea: 'AeroAndes',
        origen: 'Loja',
        destino: 'Guayaquil',
        fecha: '2026-06-20',
        horaSalida: '08:00:00',
        horaLlegada: '09:00:00',
        precio: 85,
        asientosDisponibles: 12,
        fechaDesactivacion: null,
        reservasRelacionadas: 2,
      ),
    ],
  );

  Future<void> pumpDashboard(
    WidgetTester tester, {
    Size size = const Size(1440, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AeroTechTheme.light,
        home: const AdminDashboardPage(initialData: data),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard administrativo', (tester) async {
    await pumpDashboard(tester);
    await expectLater(
      find.byType(AdminDashboardPage),
      matchesGoldenFile('goldens/admin_dashboard.png'),
    );
  });

  testWidgets('auditoría de vuelos inactivos', (tester) async {
    await pumpDashboard(tester);
    await tester.tap(find.text('Auditoría'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AdminDashboardPage),
      matchesGoldenFile('goldens/admin_auditoria.png'),
    );
  });

  testWidgets('dashboard administrativo móvil', (tester) async {
    await pumpDashboard(tester, size: const Size(390, 844));
    await expectLater(
      find.byType(AdminDashboardPage),
      matchesGoldenFile('goldens/admin_dashboard_mobile.png'),
    );
  });

  testWidgets('auditoría móvil', (tester) async {
    await pumpDashboard(tester, size: const Size(390, 844));
    await tester.tap(find.text('Auditoría'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AdminDashboardPage),
      matchesGoldenFile('goldens/admin_auditoria_mobile.png'),
    );
  });
}
