import 'package:flutter/material.dart';
import '../models/vuelo.dart';

class VueloCard extends StatelessWidget {
  final Vuelo vuelo;
  final VoidCallback onReservar;

  const VueloCard({
    super.key,
    required this.vuelo,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.flight_takeoff,
              color: Colors.blue,
              size: 34,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${vuelo.origen} → ${vuelo.destino}",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(vuelo.aerolinea),
                  const SizedBox(height: 4),
                  Text(
                    "${vuelo.fecha} | ${vuelo.horaSalida} - ${vuelo.horaLlegada}",
                  ),
                  const SizedBox(height: 4),
                  Text("Asientos disponibles: ${vuelo.asientosDisponibles}"),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "\$${vuelo.precio.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: onReservar,
                    child: const Text("Reservar"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}