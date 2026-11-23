import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/reserva.dart';
import '../models/vuelo.dart';
import '../pages/seleccion_asientos_page.dart';
import '../services/reservas_service.dart';
import '../services/session_service.dart';
import '../utils/pdf_download.dart';
import '../widgets/reserva_card.dart';
import '../utils/navigation_observer.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> with RouteAware {
  final ReservasService reservasService = ReservasService();
  List<Reserva> reservas = [];
  bool cargando = true;
  Completer<void>? _actualizacionActiva;
  Timer? _temporizadorActualizacion;
  bool _rutaVisible = true;
  String mensaje = "";

  String _firmaReservas(List<Reserva> lista) => lista
      .map(
        (r) =>
            '${r.id}:${r.estado}:${r.total}:${r.modificada}:${r.asientos.join(',')}',
      )
      .join('|');

  Future<void> cargar({bool silencioso = false}) async {
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
        mensaje = "";
      });
    }
    try {
      final data = await reservasService.listarMisReservas();
      if (!mounted) return;
      final cambioRemoto = silencioso &&
          reservas.isNotEmpty &&
          _firmaReservas(reservas) != _firmaReservas(data);
      setState(() => reservas = data);
      if (cambioRemoto && _rutaVisible) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                "Una reserva cambió mientras esta pantalla estaba abierta. Actualizamos automáticamente su estado, asientos y total.",
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } on SesionExpiradaException {
      return;
    } catch (e) {
      if (!mounted) return;
      if (!silencioso) {
        setState(
          () => mensaje = e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      ciclo.complete();
      if (identical(_actualizacionActiva, ciclo)) _actualizacionActiva = null;
      if (!silencioso && mounted) setState(() => cargando = false);
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
    } on ConflictoConcurrenciaException catch (e) {
      await cargar(silencioso: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.mensaje),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  Future<void> descargarBoletos(Reserva reserva) async {
    try {
      final pdf = await reservasService.descargarBoletos(reserva.id);
      descargarPdf(pdf, "flygo-${reserva.codigoReserva}.pdf");
    } catch (error) {
      if (!mounted) return;
      final detalle = error.toString().replaceFirst("Exception: ", "");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(detalle),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    cargar();
    _iniciarActualizacionAutomatica();
  }

  void _iniciarActualizacionAutomatica() {
    _temporizadorActualizacion?.cancel();
    _temporizadorActualizacion = Timer.periodic(
      const Duration(seconds: 10),
      (_) => cargar(silencioso: true),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ruta = ModalRoute.of(context);
    if (ruta is PageRoute) flyGoRouteObserver.subscribe(this, ruta);
  }

  @override
  void didPushNext() {
    _rutaVisible = false;
    _temporizadorActualizacion?.cancel();
  }

  @override
  void didPopNext() {
    _rutaVisible = true;
    cargar(silencioso: true);
    _iniciarActualizacionAutomatica();
  }

  @override
  void dispose() {
    flyGoRouteObserver.unsubscribe(this);
    _temporizadorActualizacion?.cancel();
    super.dispose();
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
                              Icon(Icons.error_outline,
                                  color: Colors.red.shade700),
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
                                  Icon(Icons.confirmation_number_outlined,
                                      size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No tienes ninguna reserva registrada.",
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Vuelve a la pantalla principal para buscar vuelos.",
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 13),
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
                                  onDescargar: kIsWeb && r.estado == "ACTIVA"
                                      ? () => descargarBoletos(r)
                                      : null,
                                  onEditar: r.modificada
                                      ? null
                                      : () {
                                          final vuelo = Vuelo(
                                            id: r.vueloId,
                                            aerolinea: r.aerolinea,
                                            origen: r.origen,
                                            destino: r.destino,
                                            fecha: r.fechaVuelo,
                                            horaSalida: r.horaSalida,
                                            horaLlegada: r.horaLlegada,
                                            precio: r.precioActual,
                                            asientosDisponibles: 0,
                                          );

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SeleccionAsientosPage(
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
