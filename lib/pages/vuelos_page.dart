import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/vuelo.dart';
import '../services/vuelos_service.dart';
import '../services/admin_vuelo_service.dart';
import '../widgets/vuelo_card.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'reservas_page.dart';
import 'seleccion_asientos_page.dart';
import 'crear_vuelo_page.dart';

class VuelosPage extends StatefulWidget {
  const VuelosPage({super.key});

  @override
  State<VuelosPage> createState() => _VuelosPageState();
}

class _VuelosPageState extends State<VuelosPage> {
  final origenCtrl = TextEditingController(text: "Quito");
  final destinoCtrl = TextEditingController(text: "Guayaquil");
  final fechaInicioCtrl = TextEditingController(text: "2026-06-10");
  final fechaFinCtrl = TextEditingController(text: "2026-06-20");

  final VuelosService vuelosService = VuelosService();

  List<Vuelo> vuelos = [];
  bool cargando = false;
  String mensaje = "";

  bool get esAdmin => ApiConfig.rol == "admin";

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
        fechaInicio: fechaInicioCtrl.text.trim(),
        fechaFin: fechaFinCtrl.text.trim(),
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

  Future<void> _seleccionarFechaInicio(BuildContext context) async {
    final dateFin = DateTime.tryParse(fechaFinCtrl.text) ?? DateTime.now().add(const Duration(days: 365 * 2));
    final initial = DateTime.tryParse(fechaInicioCtrl.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(dateFin) ? dateFin : initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: dateFin, // Control: deshabilitar fechas posteriores a la fecha de fin
    );
    if (picked != null) {
      setState(() {
        fechaInicioCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _seleccionarFechaFin(BuildContext context) async {
    final dateInicio = DateTime.tryParse(fechaInicioCtrl.text) ?? DateTime.now();
    final initial = DateTime.tryParse(fechaFinCtrl.text) ?? dateInicio;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(dateInicio) ? dateInicio : initial,
      firstDate: dateInicio, // Control: deshabilitar fechas anteriores a la fecha de inicio
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        fechaFinCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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

  Future<void> confirmarEliminacion(Vuelo vuelo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text("Eliminar Vuelo"),
          ],
        ),
        content: Text("¿Está seguro de que desea eliminar el vuelo de ${vuelo.origen} a ${vuelo.destino} con ${vuelo.aerolinea}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        cargando = true;
      });
      try {
        await AdminVueloService().eliminarVuelo(vuelo.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Vuelo eliminado correctamente."),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        buscar();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al eliminar vuelo: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            cargando = false;
          });
        }
      }
    }
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
    fechaInicioCtrl.dispose();
    fechaFinCtrl.dispose();
    super.dispose();
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700, size: 20),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Buscar Vuelos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          if (!esAdmin)
            IconButton(
              onPressed: abrirMisReservas,
              icon: const Icon(Icons.confirmation_number_outlined),
              tooltip: "Mis reservas",
            ),
          if (esAdmin)
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
              icon: const Icon(Icons.add_circle_outline),
              tooltip: "Registrar vuelo",
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
      body: Column(
        children: [
          // Elegant Search Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: inputField(
                            controller: origenCtrl,
                            label: "Origen",
                            icon: Icons.location_on,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: inputField(
                            controller: destinoCtrl,
                            label: "Destino",
                            icon: Icons.place,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Date range selection controls
                    Row(
                      children: [
                        Expanded(
                          child: inputField(
                            controller: fechaInicioCtrl,
                            label: "Fecha Inicio",
                            icon: Icons.calendar_month,
                            readOnly: true,
                            onTap: () => _seleccionarFechaInicio(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: inputField(
                            controller: fechaFinCtrl,
                            label: "Fecha Fin",
                            icon: Icons.calendar_today,
                            readOnly: true,
                            onTap: () => _seleccionarFechaFin(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                        ),
                        onPressed: cargando ? null : buscar,
                        icon: const Icon(Icons.search, size: 20),
                        label: Text(
                          cargando ? "Buscando..." : "Buscar Vuelos",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Error Feedback
          if (mensaje.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
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

          // Flight List results
          Expanded(
            child: cargando
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : vuelos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flight_outlined, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              "No se encontraron vuelos disponibles.",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: vuelos.length,
                        itemBuilder: (context, index) {
                          final vuelo = vuelos[index];
                          return VueloCard(
                            vuelo: vuelo,
                            onReservar: () => abrirSeleccionAsientos(vuelo),
                            onEliminar: esAdmin ? () => confirmarEliminacion(vuelo) : null,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}