import 'package:flutter/material.dart';

import '../theme/aerotech_theme.dart';

class ServidorNoDisponiblePanel extends StatefulWidget {
  final VoidCallback onReintentar;
  final bool compacto;

  const ServidorNoDisponiblePanel({
    super.key,
    required this.onReintentar,
    this.compacto = false,
  });

  @override
  State<ServidorNoDisponiblePanel> createState() =>
      _ServidorNoDisponiblePanelState();
}

class _ServidorNoDisponiblePanelState extends State<ServidorNoDisponiblePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _controller
        ..stop()
        ..value = .5;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compacto;
    return Semantics(
      liveRegion: true,
      label: 'Servicio temporalmente no disponible. Su sesión continúa activa.',
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AeroColors.line),
          boxShadow: [
            BoxShadow(
              color: AeroColors.navy.withValues(alpha: .06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: compact
            ? Row(
                children: [
                  SizedBox(
                    width: 82,
                    child: _FlightHoldAnimation(
                      controller: _controller,
                      height: 72,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: _copy(compact: true)),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: _FlightHoldAnimation(
                      controller: _controller,
                      height: 78,
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(child: _copy()),
                ],
              ),
      ),
    );
  }

  Widget _copy({bool compact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estamos esperando autorización para despegar',
          style: TextStyle(
            color: AeroColors.ink,
            fontSize: compact ? 15 : 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          compact
              ? 'No podemos contactar al servidor. Revisa que Flask esté activo y vuelve a intentarlo.'
              : 'FlyGo no puede comunicarse con el servidor en este momento. '
                  'Tu sesión y los datos que ya ves permanecen seguros.',
          style: const TextStyle(
            color: AeroColors.muted,
            height: 1.4,
            fontSize: 13,
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        OutlinedButton.icon(
          onPressed: widget.onReintentar,
          icon: const Icon(Icons.sync_rounded, size: 19),
          label: const Text('Reintentar conexión'),
        ),
      ],
    );
  }
}

class _FlightHoldAnimation extends StatelessWidget {
  final AnimationController controller;
  final double height;

  const _FlightHoldAnimation({
    required this.controller,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final progress = Curves.easeInOutCubic.transform(controller.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _HoldingRoutePainter(progress: progress),
                ),
              ),
              Transform.translate(
                offset: Offset(-34 + (68 * progress), -5),
                child: Transform.rotate(
                  angle: -.08 + (.16 * progress),
                  child: child,
                ),
              ),
            ],
          );
        },
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AeroColors.navy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.flight_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _HoldingRoutePainter extends CustomPainter {
  final double progress;

  const _HoldingRoutePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final route = Paint()
      ..color = AeroColors.blue.withValues(alpha: .24)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final active = Paint()
      ..color = AeroColors.blue
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(12, size.height * .62)
      ..cubicTo(
        size.width * .28,
        size.height * .15,
        size.width * .72,
        size.height * .88,
        size.width - 12,
        size.height * .38,
      );
    canvas.drawPath(path, route);
    final metric = path.computeMetrics().first;
    final start = (metric.length * (progress - .28)).clamp(0.0, metric.length);
    final end = (metric.length * progress).clamp(0.0, metric.length);
    canvas.drawPath(metric.extractPath(start, end), active);

    final node = Paint()..color = AeroColors.coral;
    canvas.drawCircle(Offset(12, size.height * .62), 4, node);
    canvas.drawCircle(Offset(size.width - 12, size.height * .38), 4, node);
  }

  @override
  bool shouldRepaint(covariant _HoldingRoutePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
