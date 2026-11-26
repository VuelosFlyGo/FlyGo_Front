class Reserva {
  final int id;
  final int vueloId;
  final String codigoReserva;
  final int cantidadAsientos;
  final double total;
  final double precioActual;
  final String estado;
  final String fechaReserva;
  final String aerolinea;
  final String origen;
  final String destino;
  final String fechaVuelo;
  final String horaSalida;
  final String horaLlegada;
  final List<String> asientos;
  final bool modificada;
  final bool? cancelacionPermitida;

  bool get puedeCancelar => permiteCancelarEn(DateTime.now());

  bool permiteCancelarEn(DateTime ahora) {
    final salida = DateTime.tryParse('${fechaVuelo}T$horaSalida-05:00');
    return estado == 'ACTIVA' &&
        cancelacionPermitida != false &&
        salida != null &&
        salida.difference(ahora.toUtc()) >= const Duration(hours: 24);
  }

  Reserva({
    required this.id,
    required this.vueloId,
    required this.codigoReserva,
    required this.cantidadAsientos,
    required this.total,
    required this.precioActual,
    required this.estado,
    required this.fechaReserva,
    required this.aerolinea,
    required this.origen,
    required this.destino,
    required this.fechaVuelo,
    required this.horaSalida,
    required this.horaLlegada,
    required this.asientos,
    required this.modificada,
    this.cancelacionPermitida,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json["id"],
      vueloId: json["vuelo_id"] ?? 0,
      codigoReserva: json["codigo_reserva"],
      cantidadAsientos: json["cantidad_asientos"],
      total: (json["total"] as num).toDouble(),
      precioActual: (json["precio_actual"] as num?)?.toDouble() ??
          ((json["cantidad_asientos"] as int? ?? 0) > 0
              ? (json["total"] as num).toDouble() /
                  (json["cantidad_asientos"] as int)
              : 0),
      estado: json["estado"],
      fechaReserva: json["fecha_reserva"],
      aerolinea: json["aerolinea"],
      origen: json["origen"],
      destino: json["destino"],
      fechaVuelo: json["fecha_vuelo"],
      horaSalida: json["hora_salida"],
      horaLlegada: json["hora_llegada"],
      asientos:
          json["asientos"] == null ? [] : List<String>.from(json["asientos"]),
      modificada: json["modificada"] == true,
      cancelacionPermitida: json["puede_cancelar"] as bool?,
    );
  }
}
