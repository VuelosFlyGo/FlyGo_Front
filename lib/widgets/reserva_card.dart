import 'package:flutter/material.dart';
import '../models/reserva.dart';

class ReservaCard extends StatelessWidget {
  final Reserva reserva;
  final VoidCallback onCancelar;

  const ReservaCard({
    super.key,
    required this.reserva,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final bool activa = reserva.estado == "ACTIVA";
    final String asientosTexto = reserva.asientos.isEmpty
        ? "No registrado"
        : reserva.asientos.join(", ");

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
            Icon(
              Icons.confirmation_number,
              color: activa ? Colors.green : Colors.red,
              size: 32,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reserva.codigoReserva,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text("${reserva.origen} → ${reserva.destino}"),

                  const SizedBox(height: 4),

                  Text("${reserva.fechaVuelo} | ${reserva.horaSalida}"),

                  const SizedBox(height: 4),

                  Text("Asientos: $asientosTexto"),

                  const SizedBox(height: 4),

                  Text(
                    "Cantidad: ${reserva.cantidadAsientos} | Total: \$${reserva.total.toStringAsFixed(2)}",
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Estado: ${reserva.estado}",
                    style: TextStyle(
                      color: activa ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            if (activa)
              IconButton(
                onPressed: onCancelar,
                icon: const Icon(Icons.delete),
                color: Colors.grey.shade700,
                tooltip: "Cancelar reserva",
              ),
          ],
        ),
      ),
    );
  }
}