class UsuarioRegistro {
  final String usuario;
  final String password;
  final String nombreCompleto;
  final String correo;
  final String cedula;

  UsuarioRegistro({
    required this.usuario,
    required this.password,
    required this.nombreCompleto,
    required this.correo,
    required this.cedula,
  });

  Map<String, dynamic> toJson() => {
        "usuario": usuario,
        "password": password,
        "nombre_completo": nombreCompleto,
        "correo": correo,
        "cedula": cedula,
      };
}
