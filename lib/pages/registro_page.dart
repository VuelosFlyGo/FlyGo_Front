import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/usuario_registro.dart';
import '../services/auth_service.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final usuarioCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final cedulaCtrl = TextEditingController();
  final AuthService authService = AuthService();
  bool cargando = false;
  String mensaje = "";

  bool _validarCedula(String cedula) {
    if (cedula.length != 10) return false;
    final provincia = int.tryParse(cedula.substring(0, 2)) ?? 0;
    if (provincia < 1 || (provincia > 24 && provincia != 30)) return false;

    final tercerDigito = int.tryParse(cedula.substring(2, 3)) ?? 0;
    if (tercerDigito < 0 || tercerDigito > 5) return false;

    final coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    int suma = 0;
    for (int i = 0; i < 9; i++) {
      int valor = (int.tryParse(cedula.substring(i, i + 1)) ?? 0) * coeficientes[i];
      if (valor >= 10) valor -= 9;
      suma += valor;
    }

    final verificador = int.tryParse(cedula.substring(9, 10)) ?? 0;
    final residuo = suma % 10;
    final digitoCalculado = residuo == 0 ? 0 : 10 - residuo;

    return digitoCalculado == verificador;
  }

  Future<void> registrar() async {
    final usuario = usuarioCtrl.text.trim();
    final password = passwordCtrl.text.trim();
    final nombre = nombreCtrl.text.trim();
    final correo = correoCtrl.text.trim();
    final cedula = cedulaCtrl.text.trim();

    if (usuario.isEmpty || password.isEmpty || nombre.isEmpty || correo.isEmpty || cedula.isEmpty) {
      setState(() => mensaje = "Todos los campos son obligatorios.");
      return;
    }

    if (usuario.length < 3) {
      setState(() => mensaje = "El usuario debe tener al menos 3 caracteres.");
      return;
    }

    if (password.length < 6) {
      setState(() => mensaje = "La contraseña debe tener al menos 6 caracteres.");
      return;
    }

    if (nombre.split(" ").length < 2) {
      setState(() => mensaje = "Por favor ingrese nombre y apellido completo.");
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(correo)) {
      setState(() => mensaje = "El correo electrónico no tiene un formato válido.");
      return;
    }

    if (!_validarCedula(cedula)) {
      setState(() => mensaje = "El número de cédula no es válido.");
      return;
    }

    setState(() {
      cargando = true;
      mensaje = "";
    });
    try {
      await authService.registrar(UsuarioRegistro(
        usuario: usuario,
        password: password,
        nombreCompleto: nombre,
        correo: correo,
        cedula: cedula,
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("¡Usuario registrado con éxito!"),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => mensaje = "No se pudo registrar: ${e.toString().replaceAll('Exception: ', '')}");
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  void dispose() {
    usuarioCtrl.dispose();
    passwordCtrl.dispose();
    nombreCtrl.dispose();
    correoCtrl.dispose();
    cedulaCtrl.dispose();
    super.dispose();
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Crear Cuenta",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Registro de Usuario",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Complete los siguientes datos para comenzar a reservar vuelos.",
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const Divider(height: 32, thickness: 1.2),
                    inputField(
                      controller: usuarioCtrl,
                      label: "Nombre de usuario",
                      icon: Icons.person,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                        LengthLimitingTextInputFormatter(20),
                      ],
                    ),
                    inputField(
                      controller: passwordCtrl,
                      label: "Contraseña",
                      icon: Icons.lock,
                      obscureText: true,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30),
                      ],
                    ),
                    inputField(
                      controller: nombreCtrl,
                      label: "Nombre completo",
                      icon: Icons.badge_outlined,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]')),
                        LengthLimitingTextInputFormatter(50),
                      ],
                    ),
                    inputField(
                      controller: correoCtrl,
                      label: "Correo electrónico",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        LengthLimitingTextInputFormatter(50),
                      ],
                    ),
                    inputField(
                      controller: cedulaCtrl,
                      label: "Número de cédula",
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: cargando ? null : registrar,
                        child: Text(
                          cargando ? "Registrando..." : "Registrar",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (mensaje.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                mensaje,
                                style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
