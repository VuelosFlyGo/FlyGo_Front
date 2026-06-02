import 'package:flutter/material.dart';
import '../models/asiento.dart';

class AsientoBoton extends StatelessWidget {
  final Asiento asiento;
  final bool seleccionado;
  final VoidCallback onTap;

  const AsientoBoton({
    super.key,
    required this.asiento,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;

    if (asiento.reservado) {
      color = Colors.red;
    } else if (seleccionado) {
      color = Colors.green;
    } else {
      color = Colors.blue;
    }

    return InkWell(
      onTap: asiento.disponible ? onTap : null,
      child: Container(
        width: 58,
        height: 48,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          asiento.numeroAsiento,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}