import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/login_request.dart';
import '../services/auth_service.dart';
import '../services/servidor_no_disponible_exception.dart';
import '../theme/aerotech_theme.dart';
import '../widgets/aerotech_logo.dart';
import '../widgets/servidor_no_disponible_panel.dart';
import 'registro_page.dart';
import 'vuelos_page.dart';

class LoginPage extends StatefulWidget {
  final bool sesionExpirada;

  const LoginPage({super.key, this.sesionExpirada = false});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usuarioCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final authService = AuthService();
  bool cargando = false;
  bool ocultar = true;
  String mensaje = '';
  bool servidorNoDisponible = false;
  bool mostrarSesionExpirada = false;
  Timer? _temporizadorAvisoSesion;

  @override
  void initState() {
    super.initState();
    mostrarSesionExpirada = widget.sesionExpirada;
    if (mostrarSesionExpirada) {
      _temporizadorAvisoSesion = Timer(const Duration(seconds: 10), () {
        if (mounted) setState(() => mostrarSesionExpirada = false);
      });
    }
  }

  void alternarVisibilidad() => setState(() => ocultar = !ocultar);

  Future<void> iniciarSesion() async {
    final usuario = usuarioCtrl.text.trim();
    final password = passwordCtrl.text.trim();
    if (usuario.isEmpty || password.isEmpty) {
      setState(() => mensaje = 'Completa tu usuario y contraseña.');
      return;
    }
    setState(() {
      cargando = true;
      mensaje = '';
      servidorNoDisponible = false;
    });
    try {
      await authService
          .login(LoginRequest(usuario: usuario, password: password));
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const VuelosPage()));
    } on ServidorNoDisponibleException {
      if (mounted) setState(() => servidorNoDisponible = true);
    } catch (_) {
      if (mounted) {
        setState(() =>
            mensaje = 'Los datos no coinciden. Revisa e inténtalo nuevamente.');
      }
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  void dispose() {
    _temporizadorAvisoSesion?.cancel();
    usuarioCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          final decoration = BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: AeroColors.navy.withValues(alpha: .12),
                  blurRadius: 42,
                  offset: const Offset(0, 18))
            ],
          );
          if (!wide) {
            final mobileWidth = (constraints.maxWidth - 36).clamp(0.0, 520.0);
            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Container(
                  width: mobileWidth,
                  decoration: decoration,
                  clipBehavior: Clip.antiAlias,
                  child: _AccessForm(state: this),
                ),
              ),
            );
          }
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1120),
                decoration: decoration,
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 660,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Expanded(flex: 11, child: _FlightVisual()),
                            Expanded(flex: 9, child: _AccessForm(state: this)),
                          ]),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FlightVisual extends StatelessWidget {
  const _FlightVisual();

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      height: 660,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/flygo-sky-background.png',
            fit: BoxFit.cover),
        DecoratedBox(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
              AeroColors.blue.withValues(alpha: .04),
              AeroColors.navy.withValues(alpha: .58)
            ]))),
        const Positioned(
          left: 8,
          right: -18,
          top: 58,
          height: 320,
          child: IgnorePointer(child: _FlyingPlane()),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 115,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: .96)
                ],
              ),
            ),
          ),
        ),
        TweenAnimationBuilder<double>(
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
                offset: Offset(0, 24 * (1 - value)), child: child),
          ),
          child: Padding(
            padding: const EdgeInsets.all(42),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const AeroTechLogo(size: 48, showWordmark: true),
              const Spacer(),
              const Text('EL MUNDO\nESTÁ MÁS CERCA.',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 43,
                      height: 1.02,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.1)),
              const SizedBox(height: 15),
              Text(
                  'Descubre vuelos disponibles y reserva tu próxima experiencia.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: .86),
                      fontSize: 16,
                      height: 1.45)),
              const SizedBox(height: 24),
              const Row(children: [
                Icon(Icons.flight_takeoff, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Vuelos en tiempo real',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700))
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _FlyingPlane extends StatefulWidget {
  const _FlyingPlane();

  @override
  State<_FlyingPlane> createState() => _FlyingPlaneState();
}

class _FlyingPlaneState extends State<_FlyingPlane>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _motion
        ..stop()
        ..value = 0;
    } else {
      _motion.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _motion,
      builder: (context, child) {
        final progress = Curves.easeInOut.transform(_motion.value);
        return Transform.translate(
          offset: Offset(-4 + progress * 12, -5 + progress * 10),
          child: Transform.rotate(
            angle: -.012 + progress * .024,
            alignment: Alignment.center,
            child: Transform.scale(scale: 1 + progress * .018, child: child),
          ),
        );
      },
      child: Image.asset(
        'assets/images/flygo-plane-cutout.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _AccessForm extends StatelessWidget {
  final _LoginPageState state;
  const _AccessForm({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 660),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 820 ? 30 : 48,
          vertical: 42),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AeroTechLogo(size: 46, showWordmark: true, light: false),
            SizedBox(height: state.servidorNoDisponible ? 24 : 48),
            const Text('Bienvenido a FlyGo',
                style: TextStyle(
                    color: AeroColors.ink,
                    fontSize: 31,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.7)),
            const SizedBox(height: 10),
            const Text('Inicia sesión y encuentra tu próximo vuelo.',
                style: TextStyle(color: AeroColors.muted, fontSize: 15)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: state.mostrarSesionExpirada
                  ? Padding(
                      key: const ValueKey('sesion-expirada'),
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7DE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF2CE67)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lock_clock_outlined,
                                color: Color(0xFF9A6700), size: 21),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tu sesión expiró',
                                    style: TextStyle(
                                      color: AeroColors.ink,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Por seguridad cerramos la sesión. Inicia sesión nuevamente para continuar.',
                                    style: TextStyle(
                                      color: AeroColors.muted,
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('sesion-vigente'),
                    ),
            ),
            SizedBox(height: state.servidorNoDisponible ? 20 : 32),
            TextField(
              controller: state.usuarioCtrl,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                LengthLimitingTextInputFormatter(25)
              ],
              decoration: const InputDecoration(
                  labelText: 'Usuario',
                  hintText: 'Tu nombre de usuario',
                  prefixIcon:
                      Icon(Icons.person_outline, color: AeroColors.blue)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: state.passwordCtrl,
              obscureText: state.ocultar,
              onSubmitted: (_) {
                if (!state.cargando) state.iniciarSesion();
              },
              inputFormatters: [LengthLimitingTextInputFormatter(30)],
              decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Tu contraseña',
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: AeroColors.blue),
                  suffixIcon: IconButton(
                      onPressed: state.alternarVisibilidad,
                      icon: Icon(state.ocultar
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined))),
            ),
            if (state.servidorNoDisponible) ...[
              const SizedBox(height: 16),
              ServidorNoDisponiblePanel(
                compacto: true,
                onReintentar: state.iniciarSesion,
              ),
            ],
            if (state.mensaje.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AeroColors.coral.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: AeroColors.coral, size: 19),
                    const SizedBox(width: 9),
                    Expanded(
                        child: Text(state.mensaje,
                            style: const TextStyle(
                                color: AeroColors.ink, fontSize: 13)))
                  ])),
            ],
            const SizedBox(height: 24),
            SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                    onPressed: state.cargando ? null : state.iniciarSesion,
                    icon: state.cargando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.arrow_forward),
                    label: Text(state.cargando
                        ? 'Preparando tu viaje...'
                        : 'Entrar a FlyGo'))),
            const SizedBox(height: 18),
            Center(
                child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                  const Text('¿Aún no tienes una cuenta?',
                      style: TextStyle(color: AeroColors.muted, fontSize: 13)),
                  TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegistroPage())),
                      child: const Text('Crear cuenta',
                          style: TextStyle(fontWeight: FontWeight.w700)))
                ])),
          ]),
    );
  }
}
