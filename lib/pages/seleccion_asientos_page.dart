import 'package:flutter/material.dart';
import '../models/asiento.dart';
import '../models/vuelo.dart';
import '../services/asiento_service.dart';
import '../services/reservas_service.dart';
import '../widgets/asiento_boton.dart';

class SeleccionAsientosPage extends StatefulWidget {
  final Vuelo vuelo;
  final int? editReservaId;
  final List<String>? asientosIniciales;

  const SeleccionAsientosPage({
    super.key,
    required this.vuelo,
    this.editReservaId,
    this.asientosIniciales,
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
    if (widget.asientosIniciales != null) {
      seleccionados = List<String>.from(widget.asientosIniciales!);
    }
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
    final bool esMiAsiento = widget.editReservaId != null && asiento.reservaId == widget.editReservaId;
    if (!asiento.disponible && !esMiAsiento) return;

    setState(() {
      if (seleccionados.contains(asiento.numeroAsiento)) {
        seleccionados.remove(asiento.numeroAsiento);
      } else {
        if (widget.editReservaId != null && seleccionados.length >= widget.asientosIniciales!.length) {
          mensaje = "Solo puede seleccionar hasta ${widget.asientosIniciales!.length} asientos.";
          return;
        }
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

    if (widget.editReservaId != null) {
      if (seleccionados.length != widget.asientosIniciales!.length) {
        setState(() {
          mensaje = "Debe seleccionar exactamente ${widget.asientosIniciales!.length} asientos.";
        });
        return;
      }
    }

    setState(() {
      reservando = true;
      mensaje = "";
    });

    try {
      if (widget.editReservaId != null) {
        await ReservasService().actualizarReservaAsientos(
          widget.editReservaId!,
          seleccionados,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text("Reserva actualizada con éxito")),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      } else {
        final respuesta = await asientoService.reservarAsientos(
          vueloId: widget.vuelo.id,
          asientos: seleccionados,
        );

        final codigo = respuesta["reserva"]["codigo_reserva"];
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text("Reserva creada con éxito: $codigo")),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      final textoError = e.toString();
      String mensajeLimpio = "No se pudo registrar la reserva. Intente nuevamente.";

      if (textoError.contains("Uno o más asientos ya no están disponibles") ||
          textoError.contains("Uno o m\\u00e1s asientos ya no est\\u00e1n disponibles") ||
          textoError.contains("asientos ya no est") ||
          textoError.contains("ya están reservados") ||
          textoError.contains("Concurrencia") ||
          textoError.contains("concurrencia")) {
        mensajeLimpio = "Concurrencia detectada: el asiento ya fue tomado por otro pasajero. Por favor seleccione otro.";
      } else if (textoError.contains("finalizados") || textoError.contains("despegado")) {
        mensajeLimpio = "El vuelo ya ha finalizado o despegado. No se pueden realizar cambios.";
      } else {
        mensajeLimpio = textoError.replaceAll("Exception: ", "");
      }

      if (!mounted) return;

      setState(() {
        mensaje = mensajeLimpio;
        if (widget.editReservaId == null) {
          seleccionados.clear();
        } else {
          seleccionados = List<String>.from(widget.asientosIniciales!);
        }
        reservando = false;
      });

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Selección de Asientos",
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
      body: Column(
        children: [
          // Flight summary card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.flight_takeoff, color: Colors.blue.shade800, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${vuelo.origen} → ${vuelo.destino}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${vuelo.aerolinea} | ${vuelo.fecha}",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          Text(
                            "Horario: ${vuelo.horaSalida.substring(0, 5)} - ${vuelo.horaLlegada.substring(0, 5)}",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 20, thickness: 1),
                    Text(
                      "\$${vuelo.precio.toStringAsFixed(2)} / c.u",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Legend Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _leyenda(Colors.blue.shade100, Colors.blue.shade800, "Disponible"),
                _leyenda(Colors.green.shade600, Colors.white, "Seleccionado"),
                _leyenda(Colors.red.shade50, Colors.red.shade800, "Reservado"),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Cabin Graphic header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: const Center(
              child: Text(
                "FRENTE DEL AVIÓN / CABINA",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
          ),

          // Cabin seat grid
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(
                  vertical: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
              ),
              child: cargando
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: asientos.map((asiento) {
                            return AsientoBoton(
                              asiento: asiento,
                              seleccionado: seleccionados.contains(asiento.numeroAsiento),
                              habilitado: widget.editReservaId != null && asiento.reservaId == widget.editReservaId,
                              onTap: () => cambiarSeleccion(asiento),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ),

          // Checkout section footer
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Asientos: ${seleccionados.isEmpty ? 'Ninguno' : seleccionados.join(", ")}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Total a Pagar",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      Text(
                        "\$${total.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (mensaje.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: mensaje.contains("Concurrencia") ? Colors.orange.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: mensaje.contains("Concurrencia") ? Colors.orange.shade300 : Colors.red.shade300,
                          ),
                        ),
                        child: Text(
                          mensaje,
                          style: TextStyle(
                            color: mensaje.contains("Concurrencia") ? Colors.orange.shade900 : Colors.red.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: (reservando || seleccionados.isEmpty) ? null : reservar,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        reservando ? "Reservando..." : "Confirmar Reserva",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leyenda(Color color, Color textColor, String texto) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: textColor.withOpacity(0.3)),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}