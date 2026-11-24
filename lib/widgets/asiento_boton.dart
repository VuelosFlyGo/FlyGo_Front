import 'package:flutter/material.dart';
import '../models/asiento.dart';
import '../theme/aerotech_theme.dart';

class AsientoBoton extends StatelessWidget {
  final Asiento asiento;
  final bool seleccionado;
  final VoidCallback onTap;
  final bool habilitado;

  const AsientoBoton({
    super.key,
    required this.asiento,
    required this.seleccionado,
    required this.onTap,
    this.habilitado = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData seatIcon;

    if (asiento.reservado && !seleccionado) {
      bgColor = const Color(0xFFF1F3F7);
      borderColor = const Color(0xFFCAD1DE);
      textColor = const Color(0xFF8A93A5);
      seatIcon = Icons.lock_outline;
    } else if (seleccionado) {
      bgColor = AeroColors.blue;
      borderColor = AeroColors.blue;
      textColor = Colors.white;
      seatIcon = Icons.check_rounded;
    } else {
      bgColor = const Color(0xFFEAF1FF);
      borderColor = AeroColors.cyan;
      textColor = AeroColors.navy;
      seatIcon = Icons.airline_seat_recline_normal;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            (asiento.disponible || seleccionado || habilitado) ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 52,
          height: 58,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.25),
            boxShadow: seleccionado
                ? [
                    BoxShadow(
                      color: AeroColors.blue.withValues(alpha: .24),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(seatIcon, size: 17, color: textColor),
              const SizedBox(height: 4),
              Text(
                asiento.numeroAsiento,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
