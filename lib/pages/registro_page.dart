import 'package:flutter/material.dart';
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

  Future<void> registrar() async {
    setState(() { cargando = true; mensaje = ""; });
    try {
      await authService.registrar(UsuarioRegistro(
        usuario: usuarioCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        nombreCompleto: nombreCtrl.text.trim(),
        correo: correoCtrl.text.trim(),
        cedula: cedulaCtrl.text.trim(),
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Usuario registrado")));
      Navigator.pop(context);
    } catch (e) {
      setState(() => mensaje = "No se pudo registrar: $e");
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de usuario")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: usuarioCtrl, decoration: const InputDecoration(labelText: "Usuario", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre completo", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: correoCtrl, decoration: const InputDecoration(labelText: "Correo", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: cedulaCtrl, decoration: const InputDecoration(labelText: "Cédula", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: cargando ? null : registrar, child: Text(cargando ? "Registrando..." : "Registrar"))),
            Text(mensaje, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
