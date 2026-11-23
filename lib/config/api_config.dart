class ApiConfig {
  // Puede cambiarse al ejecutar Flutter con:
  // --dart-define=API_BASE_URL=http://IP_DEL_EQUIPO:5000
  static const String baseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "http://127.0.0.1:5000",
  );

  static String token = "";
  static String rol = "cliente";
  static String usuario = "";
  static String nombreCompleto = "";
}
