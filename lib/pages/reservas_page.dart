import 'package:flutter/material.dart';
import '../models/reserva.dart';
import '../services/reservas_service.dart';
import '../widgets/reserva_card.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  final ReservasService reservasService = ReservasService();
  List<Reserva> reservas = [];
  bool cargando = true;
  String mensaje = "";

  Future<void> cargar() async {
    setState(() { cargando = true; mensaje = ""; });
    try {
      final data = await reservasService.listarMisReservas();
      setState(() => reservas = data);
    } catch (e) {
      setState(() => mensaje = e.toString());
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<void> cancelar(int id) async {
    try {
      await reservasService.cancelarReserva(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reserva cancelada")));
      cargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis reservas")),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(mensaje, style: const TextStyle(color: Colors.red)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: reservas.length,
                      itemBuilder: (context, index) => ReservaCard(
                        reserva: reservas[index],
                        onCancelar: () => cancelar(reservas[index].id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
