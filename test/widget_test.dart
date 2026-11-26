// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aerotech_reservas_app/main.dart';

void main() {
  testWidgets('FlyGo muestra el acceso', (WidgetTester tester) async {
    await tester.pumpWidget(const FlyGoApp(sesionRestaurada: false));
    expect(find.text('Bienvenido a FlyGo'), findsOneWidget);
    expect(find.text('Entrar a FlyGo'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('el login muestra el vencimiento durante diez segundos',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FlyGoApp(
      sesionRestaurada: false,
      sesionExpiradaAlAbrir: true,
    ));
    expect(find.text('Tu sesión expiró'), findsOneWidget);

    await tester.pump(const Duration(seconds: 9));
    expect(find.text('Tu sesión expiró'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Tu sesión expiró'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
