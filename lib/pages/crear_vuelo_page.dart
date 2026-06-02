import 'package:flutter/material.dart';
import '../services/admin_vuelo_service.dart';

class CrearVueloPage extends StatefulWidget {
  const CrearVueloPage({super.key});

  @override
  State<CrearVueloPage> createState() => _CrearVueloPageState();
}

class _CrearVueloPageState extends State<CrearVueloPage> {
  final aerolineaCtrl = TextEditingController(text: "AeroAndes");
  final origenCtrl = TextEditingController(text: "Quito");
  final destinoCtrl = TextEditingController(text: "Guayaquil");
  final fechaCtrl = TextEditingController(text: "2026-06-20");
  final horaSalidaCtrl = TextEditingController(text: "08:00");
  final horaLlegadaCtrl = TextEditingController(text: "09:00");
  final precioCtrl = TextEditingController(text: "85.00");
  final cantidadAsientosCtrl = TextEditingController(text: "12");

  final AdminVueloService adminVueloService = AdminVueloService();

  bool guardando = false;
  String mensaje = "";
  bool exito = false;

  Future<void> crearVuelo() async {
    setState(() {
      guardando = true;
      mensaje = "";
      exito = false;
    });

    try {
      final respuesta = await adminVueloService.crearVuelo(
        aerolinea: aerolineaCtrl.text.trim(),
        origen: origenCtrl.text.trim(),
        destino: destinoCtrl.text.trim(),
        fecha: fechaCtrl.text.trim(),
        horaSalida: horaSalidaCtrl.text.trim(),
        horaLlegada: horaLlegadaCtrl.text.trim(),
        precio: double.parse(precioCtrl.text.trim()),
        cantidadAsientos: int.parse(cantidadAsientosCtrl.text.trim()),
      );

      final vuelo = respuesta["vuelo"];

      setState(() {
        exito = true;
        mensaje =
            "Vuelo creado correctamente\n"
            "ID: ${vuelo["id"]}\n"
            "Asientos generados: ${vuelo["asientos_generados"].join(", ")}";
      });
    } catch (e) {
      setState(() {
        exito = false;
        mensaje = "Error: $e";
      });
    } finally {
      setState(() {
        guardando = false;
      });
    }
  }

  @override
  void dispose() {
    aerolineaCtrl.dispose();
    origenCtrl.dispose();
    destinoCtrl.dispose();
    fechaCtrl.dispose();
    horaSalidaCtrl.dispose();
    horaLlegadaCtrl.dispose();
    precioCtrl.dispose();
    cantidadAsientosCtrl.dispose();
    super.dispose();
  }

  Widget campo({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Crear vuelo"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: SizedBox(
            width: 520,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Registro de nuevo vuelo",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Al crear el vuelo, el sistema generará automáticamente los asientos.",
                    ),

                    const SizedBox(height: 18),

                    campo(
                      controller: aerolineaCtrl,
                      label: "Aerolínea",
                      icon: Icons.flight,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: campo(
                            controller: origenCtrl,
                            label: "Origen",
                            icon: Icons.location_on,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: campo(
                            controller: destinoCtrl,
                            label: "Destino",
                            icon: Icons.place,
                          ),
                        ),
                      ],
                    ),

                    campo(
                      controller: fechaCtrl,
                      label: "Fecha YYYY-MM-DD",
                      icon: Icons.calendar_month,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: campo(
                            controller: horaSalidaCtrl,
                            label: "Hora salida HH:MM",
                            icon: Icons.schedule,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: campo(
                            controller: horaLlegadaCtrl,
                            label: "Hora llegada HH:MM",
                            icon: Icons.access_time,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: campo(
                            controller: precioCtrl,
                            label: "Precio",
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: campo(
                            controller: cantidadAsientosCtrl,
                            label: "Cantidad de asientos",
                            icon: Icons.event_seat,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: guardando ? null : crearVuelo,
                        icon: const Icon(Icons.save),
                        label: Text(
                          guardando ? "Guardando..." : "Crear vuelo",
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (mensaje.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: exito
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: exito ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Text(
                          mensaje,
                          style: TextStyle(
                            color: exito
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                          ),
                        ),
                      ),
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