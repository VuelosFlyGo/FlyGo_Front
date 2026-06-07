class LoginResponse {
  final String token;
  final String expiracion;
  final String usuario;
  final String nombreCompleto;
  final String rol;

  LoginResponse({
    required this.token,
    required this.expiracion,
    required this.usuario,
    required this.nombreCompleto,
    required this.rol,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json["token"],
      expiracion: json["expiracion"],
      usuario: json["usuario"]["usuario"],
      nombreCompleto: json["usuario"]["nombre_completo"],
      rol: json["usuario"]["rol"] ?? "cliente",
    );
  }
}
