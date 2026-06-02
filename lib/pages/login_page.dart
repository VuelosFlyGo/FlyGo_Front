import 'package:flutter/material.dart';
import '../models/login_request.dart';
import '../services/auth_service.dart';
import 'registro_page.dart';
import 'vuelos_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usuarioCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final AuthService authService = AuthService();
  bool cargando = false;
  String mensaje = "";

  Future<void> iniciarSesion() async {
    setState(() {
      cargando = true;
      mensaje = "";
    });

    try {
      await authService.login(LoginRequest(
        usuario: usuarioCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      ));

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VuelosPage()));
    } catch (e) {
      setState(() => mensaje = "Usuario o contraseña incorrectos");
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SizedBox(
          width: 420,
          child: Card(
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flight, size: 70, color: Colors.blue),
                  const Text("AeroTech Reservas", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(controller: usuarioCtrl, decoration: const InputDecoration(labelText: "Usuario", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 12),
                  TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder(), prefixIcon: Icon(Icons.key))),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: cargando ? null : iniciarSesion,
                      icon: const Icon(Icons.login),
                      label: Text(cargando ? "Validando..." : "Iniciar sesión"),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistroPage())),
                    child: const Text("Crear cuenta"),
                  ),
                  Text(mensaje, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
