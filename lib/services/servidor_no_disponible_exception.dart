class ServidorNoDisponibleException implements Exception {
  const ServidorNoDisponibleException();

  @override
  String toString() => 'El servicio de FlyGo no está disponible temporalmente.';
}
