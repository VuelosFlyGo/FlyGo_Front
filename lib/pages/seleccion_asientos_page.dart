import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/asiento.dart';
import '../models/vuelo.dart';
import '../services/asiento_service.dart';
import '../services/reservas_service.dart';
import '../services/session_service.dart';
import '../utils/pdf_download.dart';
import '../widgets/cabina_asientos.dart';
import '../utils/navigation_observer.dart';

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

class _SeleccionAsientosPageState extends State<SeleccionAsientosPage>
    with RouteAware {
  final AsientoService asientoService = AsientoService();

  List<Asiento> asientos = [];
  List<String> seleccionados = [];

  bool cargando = true;
  bool reservando = false;
  Completer<void>? _actualizacionActiva;
  Timer? _temporizadorActualizacion;
  String mensaje = "";

  @override
  void initState() {
    super.initState();
    if (widget.asientosIniciales != null) {
      seleccionados = List<String>.from(widget.asientosIniciales!);
    }
    cargarAsientos();
    _iniciarActualizacionAutomatica();
  }

  void _iniciarActualizacionAutomatica() {
    _temporizadorActualizacion?.cancel();
    _temporizadorActualizacion = Timer.periodic(
      const Duration(seconds: 5),
      (_) => cargarAsientos(silencioso: true),
    );
  }

  Future<void> cargarAsientos({
    bool limpiarMensaje = true,
    bool silencioso = false,
  }) async {
    if (_actualizacionActiva != null) {
      if (silencioso) return;
      await _actualizacionActiva!.future;
      if (!mounted) return;
    }
    final ciclo = Completer<void>();
    _actualizacionActiva = ciclo;
    if (!silencioso && mounted) {
      setState(() {
        cargando = true;
        if (limpiarMensaje) mensaje = "";
      });
    }

    try {
      final data = await asientoService.listarAsientos(widget.vuelo.id);
      if (!mounted) return;
      final validos = data
          .where((asiento) {
            final esMio = widget.editReservaId != null &&
                asiento.reservaId == widget.editReservaId;
            return asiento.disponible || esMio;
          })
          .map((asiento) => asiento.numeroAsiento)
          .toSet();
      final retirados =
          seleccionados.where((id) => !validos.contains(id)).toList();
      setState(() {
        asientos = data;
        if (retirados.isNotEmpty) {
          seleccionados.removeWhere(retirados.contains);
          mensaje = retirados.length == 1
              ? "El asiento ${retirados.first} acaba de ser reservado por otra persona. Actualizamos el mapa automáticamente; seleccione otro asiento."
              : "Los asientos ${retirados.join(', ')} fueron reservados por otra persona. Actualizamos el mapa automáticamente; seleccione otros asientos.";
        }
      });
    } on SesionExpiradaException {
      return;
    } catch (e) {
      if (!mounted) return;
      if (!silencioso) {
        setState(() => mensaje = "No se pudieron cargar los asientos.");
      }
    } finally {
      ciclo.complete();
      if (identical(_actualizacionActiva, ciclo)) _actualizacionActiva = null;
      if (!silencioso && mounted) setState(() => cargando = false);
    }
  }

  void cambiarSeleccion(Asiento asiento) {
    final bool esMiAsiento = widget.editReservaId != null &&
        asiento.reservaId == widget.editReservaId;
    if (!asiento.disponible && !esMiAsiento) return;

    setState(() {
      if (seleccionados.contains(asiento.numeroAsiento)) {
        seleccionados.remove(asiento.numeroAsiento);
      } else {
        seleccionados.add(asiento.numeroAsiento);
      }
      mensaje = "";
    });
  }

  double get total {
    return asientos
            .where((asiento) => seleccionados.contains(asiento.numeroAsiento))
            .fold<int>(
                0,
                (suma, asiento) =>
                    suma +
                    ((asiento.precio ?? widget.vuelo.precio) * 100).round()) /
        100;
  }

  bool get hayCambioReal {
    if (widget.editReservaId == null) return seleccionados.isNotEmpty;
    final originales = widget.asientosIniciales ?? const <String>[];
    if (seleccionados.length != originales.length) return true;
    return !seleccionados.toSet().containsAll(originales);
  }

  Future<bool> confirmarCambioDefinitivo(double totalConfirmado) async {
    final originales = widget.asientosIniciales?.length ?? 0;
    final adicionales = seleccionados.length - originales;
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(Icons.lock_clock_outlined, size: 42),
            title: const Text("Confirmar cambio definitivo"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "¿Está seguro? Después de confirmar no podrá cambiar nuevamente los asientos de esta reserva.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Text(
                  "${seleccionados.length} asientos · \$${totalConfirmado.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (adicionales > 0)
                  Text(
                    "+$adicionales ${adicionales == 1 ? 'asiento adicional' : 'asientos adicionales'}",
                    style: const TextStyle(color: Colors.green),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text("Volver y revisar"),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(dialogContext, true),
                icon: const Icon(Icons.lock_outline),
                label: const Text("Sí, confirmar"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> reservar() async {
    final totalConfirmado = total;
    final asientosConfirmados = List<String>.of(seleccionados);
    if (seleccionados.isEmpty) {
      setState(() {
        mensaje = "Debe seleccionar al menos un asiento.";
      });
      return;
    }

    if (widget.editReservaId != null) {
      if (seleccionados.length < widget.asientosIniciales!.length) {
        setState(() {
          mensaje =
              "Debe conservar al menos ${widget.asientosIniciales!.length} asientos. Puede reemplazarlos o añadir más.";
        });
        return;
      }
      if (!hayCambioReal) {
        setState(() {
          mensaje =
              "Seleccione al menos un asiento diferente antes de confirmar. Su único cambio solo se utilizará cuando exista una modificación real.";
        });
        return;
      }
      final confirmado = await confirmarCambioDefinitivo(totalConfirmado);
      if (!confirmado || !mounted) return;
    }

    setState(() {
      reservando = true;
      mensaje = "";
    });

    try {
      if (widget.editReservaId != null) {
        await ReservasService().actualizarReservaAsientos(
          widget.editReservaId!,
          asientosConfirmados,
          totalEsperado: totalConfirmado,
        );

        if (!mounted) return;

        var pdfGenerado = false;
        if (kIsWeb) {
          try {
            final pdf = await ReservasService().descargarBoletos(
              widget.editReservaId!,
            );
            descargarPdf(pdf, "boletos-flygo-${widget.editReservaId}.pdf");
            pdfGenerado = true;
          } catch (_) {
            pdfGenerado = false;
          }
        }

        if (!mounted) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: Icon(Icons.verified_outlined,
                color: Colors.green.shade700, size: 42),
            title: const Text("Cambio confirmado"),
            content: Text(
              pdfGenerado
                  ? "La reserva fue modificada y los boletos PDF fueron generados. Ya no podrá cambiar los asientos nuevamente."
                  : kIsWeb
                      ? "La reserva fue modificada y ya no admite más cambios. No se pudo descargar el PDF; podrá intentarlo desde Mis reservas."
                      : "La reserva fue modificada y ya no admite más cambios. Los boletos PDF se pueden descargar al abrir FlyGo desde un navegador web.",
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Entendido"),
              ),
            ],
          ),
        );

        if (mounted) Navigator.pop(context, true);
      } else {
        final respuesta = await asientoService.reservarAsientos(
          vueloId: widget.vuelo.id,
          asientos: asientosConfirmados,
          totalEsperado: totalConfirmado,
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
    } on ReservaActualizadaEnOtraPestanaException {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(
            Icons.sync_problem_rounded,
            color: Colors.orange.shade800,
            size: 42,
          ),
          title: const Text("Reserva actualizada en otra pestaña"),
          content: const Text(
            "Esta misma reserva ya fue modificada y confirmada desde otra pestaña. La información de esta pantalla quedó desactualizada; volveremos a Mis reservas para mostrar los asientos definitivos.",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text("Ver mis reservas"),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } on TarifaActualizadaException {
      if (!mounted) return;
      setState(() => mensaje =
          "La tarifa cambió. Revisa el nuevo total antes de confirmar.");
      await cargarAsientos(limpiarMensaje: false);
    } on ConflictoConcurrenciaException catch (e) {
      if (!mounted) return;
      setState(() {
        mensaje = e.mensaje;
        if (widget.editReservaId == null) {
          seleccionados.clear();
        } else {
          seleccionados = List<String>.from(widget.asientosIniciales!);
        }
        reservando = false;
      });
      await cargarAsientos(limpiarMensaje: false);
    } on SesionExpiradaException {
      return;
    } catch (e) {
      final textoError = e.toString();
      String mensajeLimpio =
          "No se pudo registrar la reserva. Intente nuevamente.";

      if (textoError.contains("Uno o más asientos ya no están disponibles") ||
          textoError.contains(
              "Uno o m\\u00e1s asientos ya no est\\u00e1n disponibles") ||
          textoError.contains("asientos ya no est") ||
          textoError.contains("ya están reservados") ||
          textoError.contains("Concurrencia") ||
          textoError.contains("concurrencia")) {
        mensajeLimpio =
            "Ese asiento acaba de ser reservado por otra persona. Actualizamos la disponibilidad; seleccione otro asiento.";
      } else if (textoError.contains("ya fue modificada") ||
          textoError.contains("nuevos cambios")) {
        mensajeLimpio =
            "Esta reserva ya fue modificada y no puede cambiarse nuevamente.";
      } else if (textoError.contains("finalizados") ||
          textoError.contains("despegado")) {
        mensajeLimpio =
            "El vuelo ya ha finalizado o despegado. No se pueden realizar cambios.";
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
  void dispose() {
    flyGoRouteObserver.unsubscribe(this);
    _temporizadorActualizacion?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ruta = ModalRoute.of(context);
    if (ruta is PageRoute) flyGoRouteObserver.subscribe(this, ruta);
  }

  @override
  void didPushNext() => _temporizadorActualizacion?.cancel();

  @override
  void didPopNext() {
    cargarAsientos(silencioso: true);
    _iniciarActualizacionAutomatica();
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
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
                      child: Icon(Icons.flight_takeoff,
                          color: Colors.blue.shade800, size: 28),
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
                            [
                              vuelo.aerolinea,
                              if (vuelo.avionModelo != null) vuelo.avionModelo!,
                              vuelo.fecha,
                            ].join(' · '),
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                          Text(
                            "Horario: ${vuelo.horaSalida.substring(0, 5)} - ${vuelo.horaLlegada.substring(0, 5)}",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : CabinaAsientos(
                    asientos: asientos,
                    seleccionados: seleccionados,
                    reservaId: widget.editReservaId,
                    onAsientoTap: cambiarSeleccion,
                  ),
          ),

          // Checkout section footer
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .06),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Asientos: ${seleccionados.isEmpty ? 'Ninguno' : seleccionados.join(", ")}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Total a pagar",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
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
                          color: mensaje.contains("acaba de ser reservado")
                              ? Colors.orange.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: mensaje.contains("acaba de ser reservado")
                                ? Colors.orange.shade300
                                : Colors.red.shade300,
                          ),
                        ),
                        child: Text(
                          mensaje,
                          style: TextStyle(
                            color: mensaje.contains("acaba de ser reservado")
                                ? Colors.orange.shade900
                                : Colors.red.shade900,
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
                      onPressed: (reservando ||
                              cargando ||
                              asientos.isEmpty ||
                              !hayCambioReal)
                          ? null
                          : reservar,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        reservando
                            ? "Confirmando..."
                            : widget.editReservaId != null && !hayCambioReal
                                ? "Seleccione un asiento diferente"
                                : seleccionados.isEmpty
                                    ? "Seleccione un asiento"
                                    : widget.editReservaId != null
                                        ? "Confirmar cambio definitivo"
                                        : "Confirmar reserva",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
}
