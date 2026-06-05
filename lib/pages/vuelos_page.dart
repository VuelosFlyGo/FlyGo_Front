import 'package:flutter/material.dart';
import '../models/vuelo.dart';
import '../services/vuelos_service.dart';
import '../widgets/vuelo_card.dart';
import 'reservas_page.dart';
import 'seleccion_asientos_page.dart';
import 'crear_vuelo_page.dart';
import 'login_page.dart';
import '../services/auth_service.dart';

class VuelosPage extends StatefulWidget {
  const VuelosPage({super.key});

  @override
  State<VuelosPage> createState() => _VuelosPageState();
}

class _VuelosPageState extends State<VuelosPage> {
  final origenCtrl = TextEditingController(text: "Quito");
  final destinoCtrl = TextEditingController(text: "Guayaquil");
  final fechaCtrl = TextEditingController(text: "2026-06-10");

  final VuelosService vuelosService = VuelosService();

  List<Vuelo> vuelos = [];
  bool cargando = false;
  String mensaje = "";

  Future<void> buscar() async {
    setState(() {
      cargando = true;
      mensaje = "";
      vuelos = [];
    });

    try {
      final data = await vuelosService.buscarVuelos(
        origen: origenCtrl.text.trim(),
        destino: destinoCtrl.text.trim(),
        fecha: fechaCtrl.text.trim(),
      );

      setState(() {
        vuelos = data;
      });
    } catch (e) {
      setState(() {
        mensaje = e.toString();
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  void abrirSeleccionAsientos(Vuelo vuelo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeleccionAsientosPage(vuelo: vuelo),
      ),
    ).then((_) {
      buscar();
    });
  }

  void abrirMisReservas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReservasPage(),
      ),
    ).then((_) {
      buscar();
    });
  }

  @override
  void initState() {
    super.initState();
    buscar();
  }

  @override
  void dispose() {
    origenCtrl.dispose();
    destinoCtrl.dispose();
    fechaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Buscar vuelos"),
        centerTitle: true,
        actions: [
            IconButton(
              onPressed: abrirMisReservas,
              icon: const Icon(Icons.confirmation_number),
              tooltip: "Mis reservas",
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CrearVueloPage(),
                  ),
                ).then((_) {
                  buscar();
                });
              },
              icon: const Icon(Icons.add),
              tooltip: "Crear vuelo",
            ),
            IconButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await AuthService().logout();
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              tooltip: "Cerrar sesión",
            ),
          ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: origenCtrl,
                    decoration: const InputDecoration(
                      labelText: "Origen",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: destinoCtrl,
                    decoration: const InputDecoration(
                      labelText: "Destino",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: fechaCtrl,
                    decoration: const InputDecoration(
                      labelText: "Fecha YYYY-MM-DD",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: cargando ? null : buscar,
                icon: const Icon(Icons.search),
                label: Text(
                  cargando ? "Buscando..." : "Buscar vuelos",
                ),
              ),
            ),

            const SizedBox(height: 8),

            if (mensaje.isNotEmpty)
              Text(
                mensaje,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 8),

            Expanded(
              child: cargando
                  ? const Center(child: CircularProgressIndicator())
                  : vuelos.isEmpty
                      ? const Center(
                          child: Text("No hay vuelos disponibles."),
                        )
                      : ListView.builder(
                          itemCount: vuelos.length,
                          itemBuilder: (context, index) {
                            final vuelo = vuelos[index];

                            return VueloCard(
                              vuelo: vuelo,
                              onReservar: () {
                                abrirSeleccionAsientos(vuelo);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}