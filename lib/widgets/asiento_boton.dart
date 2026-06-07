import 'package:flutter/material.dart';
import '../models/asiento.dart';

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
      bgColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
      textColor = Colors.red.shade800;
      seatIcon = Icons.event_seat;
    } else if (seleccionado) {
      bgColor = Colors.green.shade600;
      borderColor = Colors.green.shade700;
      textColor = Colors.white;
      seatIcon = Icons.check_circle_outline;
    } else {
      bgColor = Colors.blue.shade50;
      borderColor = Colors.blue.shade300;
      textColor = Colors.blue.shade800;
      seatIcon = Icons.event_seat_outlined;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (asiento.disponible || seleccionado || habilitado) ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 65,
          height: 60,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: seleccionado
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(seatIcon, size: 16, color: textColor),
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