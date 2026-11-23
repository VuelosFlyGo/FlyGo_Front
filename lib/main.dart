import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/vuelos_page.dart';
import 'services/session_service.dart';
import 'theme/aerotech_theme.dart';
import 'utils/navigation_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool sesionRestaurada = false;
  try {
    sesionRestaurada = await SessionService.restaurar();
  } catch (_) {
    await SessionService.limpiar();
  }
  runApp(FlyGoApp(sesionRestaurada: sesionRestaurada));
}

class FlyGoApp extends StatefulWidget {
  final bool sesionRestaurada;

  const FlyGoApp({super.key, required this.sesionRestaurada});

  @override
  State<FlyGoApp> createState() => _FlyGoAppState();
}

class _FlyGoAppState extends State<FlyGoApp> {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    SessionService.sesionExpirada.addListener(_volverAlLogin);
  }

  void _volverAlLogin() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginPage(sesionExpirada: true),
      ),
      (_) => false,
    );
  }

  @override
  void dispose() {
    SessionService.sesionExpirada.removeListener(_volverAlLogin);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlyGo',
      debugShowCheckedModeBanner: false,
      theme: AeroTechTheme.light,
      navigatorKey: navigatorKey,
      navigatorObservers: [flyGoRouteObserver],
      home: widget.sesionRestaurada ? const VuelosPage() : const LoginPage(),
    );
  }
}
