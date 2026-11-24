class AdminDashboardData {
  final AdminResumen resumen;
  final List<AdminVueloResumen> proximosVuelos;
  final List<AdminVueloAuditoria> auditoria;

  const AdminDashboardData({
    required this.resumen,
    required this.proximosVuelos,
    required this.auditoria,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      resumen: AdminResumen.fromJson(json['resumen']),
      proximosVuelos: (json['proximos_vuelos'] as List)
          .map((item) => AdminVueloResumen.fromJson(item))
          .toList(),
      auditoria: (json['auditoria'] as List)
          .map((item) => AdminVueloAuditoria.fromJson(item))
          .toList(),
    );
  }
}

class AdminResumen {
  final int vuelosVigentes;
  final int vuelosFinalizados;
  final int vuelosInactivos;
  final int asientosDisponibles;
  final int reservasActivas;
  final int pasajerosConfirmados;
  final double ingresosConfirmados;
  final int clientesActivos;

  const AdminResumen({
    required this.vuelosVigentes,
    required this.vuelosFinalizados,
    required this.vuelosInactivos,
    required this.asientosDisponibles,
    required this.reservasActivas,
    required this.pasajerosConfirmados,
    required this.ingresosConfirmados,
    required this.clientesActivos,
  });

  factory AdminResumen.fromJson(Map<String, dynamic> json) => AdminResumen(
        vuelosVigentes: json['vuelos_vigentes'],
        vuelosFinalizados: json['vuelos_finalizados'],
        vuelosInactivos: json['vuelos_inactivos'],
        asientosDisponibles: json['asientos_disponibles'],
        reservasActivas: json['reservas_activas'],
        pasajerosConfirmados: json['pasajeros_confirmados'],
        ingresosConfirmados: (json['ingresos_confirmados'] as num).toDouble(),
        clientesActivos: json['clientes_activos'],
      );
}

class AdminVueloResumen {
  final int id;
  final String aerolinea;
  final String origen;
  final String destino;
  final String fecha;
  final String horaSalida;
  final String horaLlegada;
  final double precio;
  final int asientosDisponibles;

  const AdminVueloResumen({
    required this.id,
    required this.aerolinea,
    required this.origen,
    required this.destino,
    required this.fecha,
    required this.horaSalida,
    required this.horaLlegada,
    required this.precio,
    required this.asientosDisponibles,
  });

  factory AdminVueloResumen.fromJson(Map<String, dynamic> json) {
    return AdminVueloResumen(
      id: json['id'],
      aerolinea: json['aerolinea'],
      origen: json['origen'],
      destino: json['destino'],
      fecha: json['fecha'],
      horaSalida: json['hora_salida'],
      horaLlegada: json['hora_llegada'],
      precio: (json['precio'] as num).toDouble(),
      asientosDisponibles: json['asientos_disponibles'],
    );
  }
}

class AdminVueloAuditoria extends AdminVueloResumen {
  final String? fechaDesactivacion;
  final int reservasRelacionadas;

  const AdminVueloAuditoria({
    required super.id,
    required super.aerolinea,
    required super.origen,
    required super.destino,
    required super.fecha,
    required super.horaSalida,
    required super.horaLlegada,
    required super.precio,
    required super.asientosDisponibles,
    required this.fechaDesactivacion,
    required this.reservasRelacionadas,
  });

  factory AdminVueloAuditoria.fromJson(Map<String, dynamic> json) {
    return AdminVueloAuditoria(
      id: json['id'],
      aerolinea: json['aerolinea'],
      origen: json['origen'],
      destino: json['destino'],
      fecha: json['fecha'],
      horaSalida: json['hora_salida'],
      horaLlegada: json['hora_llegada'],
      precio: (json['precio'] as num).toDouble(),
      asientosDisponibles: json['asientos_disponibles'],
      fechaDesactivacion: json['fecha_desactivacion'],
      reservasRelacionadas: json['reservas_relacionadas'],
    );
  }
}
