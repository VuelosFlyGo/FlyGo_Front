class Asiento {
  final int id;
  final int vueloId;
  final String numeroAsiento;
  final String estado;
  final int? reservaId;
  final String clase;
  final double? precio;

  Asiento({
    required this.id,
    required this.vueloId,
    required this.numeroAsiento,
    required this.estado,
    this.reservaId,
    this.clase = 'TURISTA',
    this.precio,
  });

  factory Asiento.fromJson(Map<String, dynamic> json) {
    return Asiento(
      id: json["id"],
      vueloId: json["vuelo_id"],
      numeroAsiento: json["numero_asiento"],
      estado: json["estado"],
      reservaId: json["reserva_id"],
      clase: json['clase'] ?? 'TURISTA',
      precio: (json['precio'] as num?)?.toDouble(),
    );
  }

  bool get disponible => estado == "DISPONIBLE";
  bool get reservado => estado == "RESERVADO";
  bool get ejecutivo => clase == 'EJECUTIVA';
}
