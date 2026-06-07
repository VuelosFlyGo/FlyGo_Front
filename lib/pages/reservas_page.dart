import 'package:flutter/material.dart';
import '../models/reserva.dart';
import '../models/vuelo.dart';
import '../pages/seleccion_asientos_page.dart';
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
    setState(() {
      cargando = true;
      mensaje = "";
    });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("Reserva cancelada con éxito"),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      cargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Mis Reservas",
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
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: cargar,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (mensaje.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  mensaje,
                                  style: TextStyle(color: Colors.red.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: reservas.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No tienes ninguna reserva registrada.",
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Vuelve a la pantalla principal para buscar vuelos.",
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: reservas.length,
                              itemBuilder: (context, index) {
                                final r = reservas[index];
                                return ReservaCard(
                                  reserva: r,
                                  onCancelar: () => cancelar(r.id),
                                  onEditar: () {
                                    final vuelo = Vuelo(
                                      id: r.vueloId,
                                      aerolinea: r.aerolinea,
                                      origen: r.origen,
                                      destino: r.destino,
                                      fecha: r.fechaVuelo,
                                      horaSalida: r.horaSalida,
                                      horaLlegada: r.horaLlegada,
                                      precio: r.cantidadAsientos > 0 ? (r.total / r.cantidadAsientos) : 0.0,
                                      asientosDisponibles: 0,
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SeleccionAsientosPage(
                                          vuelo: vuelo,
                                          editReservaId: r.id,
                                          asientosIniciales: r.asientos,
                                        ),
                                      ),
                                    ).then((value) {
                                      if (value == true) {
                                        cargar();
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
