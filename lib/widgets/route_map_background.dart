import 'package:flutter/material.dart';
import '../theme/aerotech_theme.dart';

class RouteMapBackground extends StatefulWidget {
  const RouteMapBackground({super.key});

  @override
  State<RouteMapBackground> createState() => _RouteMapBackgroundState();
}

class _RouteMapBackgroundState extends State<RouteMapBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.stop();
      controller.value = 1;
    } else if (!controller.isAnimating) {
      controller.repeat();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _RoutePainter(controller.value),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final double progress;
  const _RoutePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .035)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 52) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 52) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = Path()
      ..moveTo(size.width * .08, size.height * .72)
      ..cubicTo(size.width * .3, size.height * .25,
          size.width * .62, size.height * .82, size.width * .92, size.height * .24);
    canvas.drawPath(
      path,
      Paint()
        ..color = AeroColors.cyan.withValues(alpha: .25)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    final metric = path.computeMetrics().first;
    final segmentLength = metric.length * .18;
    final head = metric.length * progress;
    final start = (head - segmentLength).clamp(0.0, metric.length);
    canvas.drawPath(
      metric.extractPath(start, head),
      Paint()
        ..color = AeroColors.cyan.withValues(alpha: .95)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    for (final point in [
      Offset(size.width * .08, size.height * .72),
      Offset(size.width * .92, size.height * .24),
    ]) {
      canvas.drawCircle(point, 7, Paint()..color = AeroColors.coral);
      canvas.drawCircle(
          point, 15, Paint()..color = AeroColors.coral.withValues(alpha: .15));
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
