import 'package:flutter/material.dart';
import '../models/asiento.dart';
import '../models/vuelo.dart';
import '../services/asiento_service.dart';
import '../widgets/asiento_boton.dart';

class SeleccionAsientosPage extends StatefulWidget {
  final Vuelo vuelo;

  const SeleccionAsientosPage({
    super.key,
    required this.vuelo,
  });

  @override
  State<SeleccionAsientosPage> createState() => _SeleccionAsientosPageState();
}

class _SeleccionAsientosPageState extends State<SeleccionAsientosPage> {
  final AsientoService asientoService = AsientoService();

  List<Asiento> asientos = [];
  List<String> seleccionados = [];

  bool cargando = true;
  bool reservando = false;
  String mensaje = "";

  @override
  void initState() {
    super.initState();
    cargarAsientos();
  }

  Future<void> cargarAsientos({bool limpiarMensaje = true}) async {
    setState(() {
      cargando = true;

      if (limpiarMensaje) {
        mensaje = "";
      }
    });

    try {
      final data = await asientoService.listarAsientos(widget.vuelo.id);

      if (!mounted) return;

      setState(() {
        asientos = data;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        mensaje = "No se pudieron cargar los asientos.";
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  void cambiarSeleccion(Asiento asiento) {
    if (!asiento.disponible) return;

    setState(() {
      if (seleccionados.contains(asiento.numeroAsiento)) {
        seleccionados.remove(asiento.numeroAsiento);
      } else {
        seleccionados.add(asiento.numeroAsiento);
      }
    });
  }

  double get total {
    return seleccionados.length * widget.vuelo.precio;
  }

  Future<void> reservar() async {
    if (seleccionados.isEmpty) {
      setState(() {
        mensaje = "Debe seleccionar al menos un asiento.";
      });
      return;
    }

    setState(() {
      reservando = true;
      mensaje = "";
    });

    try {
      final respuesta = await asientoService.reservarAsientos(
        vueloId: widget.vuelo.id,
        asientos: seleccionados,
      );

      final codigo = respuesta["reserva"]["codigo_reserva"];

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Reserva creada correctamente: $codigo"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      final textoError = e.toString();

      String mensajeLimpio =
          "No se pudo registrar la reserva. Intente nuevamente.";

      if (textoError.contains("Uno o más asientos ya no están disponibles") ||
          textoError.contains(
              "Uno o m\\u00e1s asientos ya no est\\u00e1n disponibles") ||
          textoError.contains("asientos ya no est") ||
          textoError.contains("No se pudo registrar la reserva")) {
        mensajeLimpio =
            "Concurrencia detectada: el asiento seleccionado ya fue reservado por otro usuario. Actualice la lista e intente nuevamente.";
      }

      if (!mounted) return;

      setState(() {
        mensaje = mensajeLimpio;
        seleccionados.clear();
        reservando = false;
      });

      // Forzamos a que el mensaje se vea antes de actualizar los asientos.
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      await cargarAsientos(limpiarMensaje: false);
    } finally {
      if (mounted) {
        setState(() {
          reservando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vuelo = widget.vuelo;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleccionar asientos"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.flight_takeoff,
                  color: Colors.blue,
                ),
                title: Text("${vuelo.origen} → ${vuelo.destino}"),
                subtitle: Text(
                  "${vuelo.aerolinea}\n${vuelo.fecha} | ${vuelo.horaSalida} - ${vuelo.horaLlegada}",
                ),
                trailing: Text(
                  "\$${vuelo.precio.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Seleccione los asientos disponibles",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                _leyenda(Colors.blue, "Disponible"),
                const SizedBox(width: 12),
                _leyenda(Colors.green, "Seleccionado"),
                const SizedBox(width: 12),
                _leyenda(Colors.red, "Reservado"),
              ],
            ),

            const SizedBox(height: 12),

            if (cargando)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    children: asientos.map((asiento) {
                      return AsientoBoton(
                        asiento: asiento,
                        seleccionado: seleccionados.contains(
                          asiento.numeroAsiento,
                        ),
                        onTap: () => cambiarSeleccion(asiento),
                      );
                    }).toList(),
                  ),
                ),
              ),

            const Divider(),

            Text("Asientos seleccionados: ${seleccionados.join(", ")}"),
            Text("Total: \$${total.toStringAsFixed(2)}"),

            const SizedBox(height: 8),

            if (mensaje.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: mensaje.contains("Concurrencia detectada")
                      ? Colors.orange.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: mensaje.contains("Concurrencia detectada")
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
                child: Text(
                  mensaje,
                  style: TextStyle(
                    color: mensaje.contains("Concurrencia detectada")
                        ? Colors.orange.shade900
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: reservando ? null : reservar,
                icon: reservando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  reservando ? "Reservando..." : "Confirmar reserva",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leyenda(Color color, String texto) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(texto),
      ],
    );
  }
}