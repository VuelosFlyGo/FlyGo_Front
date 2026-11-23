import 'package:flutter/material.dart';
import '../theme/aerotech_theme.dart';

class AeroTechLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final bool light;

  const AeroTechLogo({
    super.key,
    this.size = 44,
    this.showWordmark = false,
    this.light = true,
  });

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/flygo-mark.png',
        fit: BoxFit.contain,
        color: light ? Colors.white : AeroColors.blue,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
    if (!showWordmark) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 12),
        Text.rich(
          TextSpan(
            children: const [
              TextSpan(text: 'FLY', style: TextStyle(fontWeight: FontWeight.w900)),
              TextSpan(text: 'GO', style: TextStyle(color: AeroColors.cyan, fontWeight: FontWeight.w900)),
            ],
          ),
          style: TextStyle(color: light ? Colors.white : AeroColors.navy, fontSize: size * .42, letterSpacing: 1.6),
        ),
      ],
    );
  }
}
