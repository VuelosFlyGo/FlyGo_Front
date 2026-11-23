import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/vuelo.dart';
import '../theme/aerotech_theme.dart';

class VueloCard extends StatelessWidget {
  final Vuelo vuelo;
  final VoidCallback onReservar;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const VueloCard({
    super.key,
    required this.vuelo,
    required this.onReservar,
    this.onEditar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final String fechaStr = vuelo.fecha;
    final String horaStr = vuelo.horaSalida.substring(0, 5);
    final DateTime? departureTime =
        DateTime.tryParse("${fechaStr}T$horaStr:00");
    final bool estaFinalizado =
        departureTime != null && departureTime.isBefore(DateTime.now());

    final seatsColor = estaFinalizado
        ? AeroColors.muted
        : (vuelo.asientosDisponibles > 10
            ? AeroColors.emerald
            : (vuelo.asientosDisponibles > 0
                ? Colors.orange.shade700
                : AeroColors.coral));

    final bool esAdmin = ApiConfig.rol == "admin";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AeroColors.line),
        boxShadow: [
          BoxShadow(
            color: AeroColors.navy.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Carrier/Aesthetic Left indicator
              Container(
                width: 6,
                color: esAdmin ? AeroColors.coral : AeroColors.cyan,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Airline Logo & Core Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flight_takeoff,
                                    color: AeroColors.cyan, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  vuelo.aerolinea,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AeroColors.ink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Route Details
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vuelo.origen,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      vuelo.horaSalida.substring(0, 5),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Icon(Icons.flight,
                                      color: AeroColors.cyan, size: 18),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vuelo.destino,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      vuelo.horaLlegada.substring(0, 5),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Date & Seats Info
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  vuelo.fecha,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.event_seat,
                                    size: 14, color: seatsColor),
                                const SizedBox(width: 4),
                                Text(
                                  estaFinalizado
                                      ? "Finalizado"
                                      : "${vuelo.asientosDisponibles} disp.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: seatsColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(width: 24, thickness: 1),
                      // Price & Booking Action
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "\$${vuelo.precio.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AeroColors.navy,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Action button: Reservar for clients, Eliminar for admins
                          if (esAdmin)
                            Column(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AeroColors.navy,
                                    foregroundColor: AeroColors.cyan,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: onEditar,
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 16),
                                  label: const Text(
                                    "Editar",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                    side:
                                        BorderSide(color: Colors.red.shade200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: onEliminar,
                                  icon: const Icon(Icons.delete_outline,
                                      size: 16),
                                  label: const Text(
                                    "Eliminar",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            )
                          else if (estaFinalizado)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade400,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: null,
                              child: const Text(
                                "Finalizado",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            )
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AeroColors.navy,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: onReservar,
                              child: const Text(
                                "Reservar",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
