import 'dart:async';

import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/vuelos_page.dart';
import 'services/auth_service.dart';
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
  runApp(FlyGoApp(
    sesionRestaurada: sesionRestaurada,
    sesionExpiradaAlAbrir: SessionService.sesionExpirada.value > 0,
  ));
}

class FlyGoApp extends StatefulWidget {
  final bool sesionRestaurada;
  final bool sesionExpiradaAlAbrir;

  const FlyGoApp({
    super.key,
    required this.sesionRestaurada,
    this.sesionExpiradaAlAbrir = false,
  });

  @override
  State<FlyGoApp> createState() => _FlyGoAppState();
}

class _FlyGoAppState extends State<FlyGoApp> with WidgetsBindingObserver {
  final navigatorKey = GlobalKey<NavigatorState>();
  late final StreamSubscription<void> _cambiosSesion;
  late final StreamSubscription<void> _reactivaciones;
  late final Timer _verificacionRemota;
  final _auth = AuthService();
  bool _verificando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SessionService.sesionExpirada.addListener(_mostrarSesionExpirada);
    SessionService.sesionCerrada.addListener(_mostrarLogin);
    _cambiosSesion = SessionService.cambiosEnOtraPestana.listen(
      (_) => unawaited(SessionService.verificarSesion()),
    );
    _reactivaciones = SessionService.reactivaciones.listen(
      (_) => unawaited(_comprobarSesion()),
    );
    _verificacionRemota = Timer.periodic(
      const Duration(seconds: 3),
      (_) => unawaited(_comprobarSesion()),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_comprobarSesion());
    });
  }

  Future<void> _comprobarSesion() async {
    await SessionService.verificarSesion();
    if (!mounted || _verificando) return;
    _verificando = true;
    try {
      await _auth.comprobarSesion();
    } finally {
      _verificando = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_comprobarSesion());
    }
  }

  void _mostrarSesionExpirada() => _volverAlLogin(expirada: true);
  void _mostrarLogin() => _volverAlLogin(expirada: false);

  void _volverAlLogin({required bool expirada}) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(sesionExpirada: expirada),
      ),
      (_) => false,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SessionService.sesionExpirada.removeListener(_mostrarSesionExpirada);
    SessionService.sesionCerrada.removeListener(_mostrarLogin);
    unawaited(_cambiosSesion.cancel());
    unawaited(_reactivaciones.cancel());
    _verificacionRemota.cancel();
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
      home: widget.sesionRestaurada
          ? const VuelosPage()
          : LoginPage(sesionExpirada: widget.sesionExpiradaAlAbrir),
    );
  }
}
