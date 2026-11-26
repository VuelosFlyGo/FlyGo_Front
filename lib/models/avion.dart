class Avion {
  final int id;
  final String modelo;
  final int ejecutiva;
  final int turista;

  const Avion({
    required this.id,
    required this.modelo,
    required this.ejecutiva,
    required this.turista,
  });

  int get capacidad => ejecutiva + turista;

  factory Avion.fromJson(Map<String, dynamic> json) => Avion(
        id: json['id'],
        modelo: json['modelo'],
        ejecutiva: json['asientos_ejecutiva'],
        turista: json['asientos_turista'],
      );
}
