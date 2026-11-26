class Vuelo {
  final int id;
  final String aerolinea;
  final String origen;
  final String destino;
  final String fecha;
  final String horaSalida;
  final String horaLlegada;
  final double precio;
  final int asientosDisponibles;
  final int totalAsientos;
  final bool estado;
  final String situacion;
  final int? avionId;
  final String? avionModelo;
  final double? precioEjecutiva;
  final int ejecutivaDisponibles;
  final int turistaDisponibles;
  final int reservasActivas;

  Vuelo({
    required this.id,
    required this.aerolinea,
    required this.origen,
    required this.destino,
    required this.fecha,
    required this.horaSalida,
    required this.horaLlegada,
    required this.precio,
    required this.asientosDisponibles,
    int? totalAsientos,
    this.estado = true,
    this.situacion = "VIGENTE",
    this.avionId,
    this.avionModelo,
    this.precioEjecutiva,
    this.ejecutivaDisponibles = 0,
    int? turistaDisponibles,
    this.reservasActivas = 0,
  })  : totalAsientos = totalAsientos ?? asientosDisponibles,
        turistaDisponibles = turistaDisponibles ?? asientosDisponibles;

  double get precioDesde => turistaDisponibles > 0 || precioEjecutiva == null
      ? precio
      : precioEjecutiva!;

  Duration get duracion {
    int minutos(String hora) {
      final partes = hora.split(':');
      return int.parse(partes[0]) * 60 + int.parse(partes[1]);
    }

    return Duration(
        minutes: (minutos(horaLlegada) - minutos(horaSalida)) % 1440);
  }

  factory Vuelo.fromJson(Map<String, dynamic> json) {
    return Vuelo(
      id: json["id"],
      aerolinea: json["aerolinea"],
      origen: json["origen"],
      destino: json["destino"],
      fecha: json["fecha"],
      horaSalida: json["hora_salida"],
      horaLlegada: json["hora_llegada"],
      precio: (json["precio"] as num).toDouble(),
      asientosDisponibles: json["asientos_disponibles"],
      totalAsientos: json["total_asientos"],
      estado: json["estado"] ?? true,
      situacion: json["situacion"] ?? "VIGENTE",
      avionId: json["avion_id"],
      avionModelo: json["avion_modelo"],
      precioEjecutiva: (json["precio_ejecutiva"] as num?)?.toDouble(),
      ejecutivaDisponibles: json["ejecutiva_disponibles"] ?? 0,
      turistaDisponibles: json["turista_disponibles"],
      reservasActivas: json["reservas_activas"] ?? 0,
    );
  }
}
