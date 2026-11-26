import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vuelo.dart';
import '../models/avion.dart';
import '../widgets/vista_previa_avion.dart';
import '../services/admin_vuelo_service.dart';
import '../theme/aerotech_theme.dart';
import '../widgets/aerotech_logo.dart';

class CrearVueloPage extends StatefulWidget {
  final Vuelo? vuelo;
  const CrearVueloPage({super.key, this.vuelo});

  @override
  State<CrearVueloPage> createState() => _CrearVueloPageState();
}

class _CrearVueloPageState extends State<CrearVueloPage> {
  late final TextEditingController aerolineaCtrl;
  late final TextEditingController origenCtrl;
  late final TextEditingController destinoCtrl;
  late final TextEditingController fechaCtrl;
  late final TextEditingController horaSalidaCtrl;
  late final TextEditingController horaLlegadaCtrl;
  late final TextEditingController precioCtrl;
  late final TextEditingController precioEjecutivaCtrl;
  List<Avion> aviones = [];
  int? avionId;
  bool cargandoAviones = true;
  bool errorAviones = false;

  final AdminVueloService adminVueloService = AdminVueloService();

  bool guardando = false;
  String mensaje = "";
  bool exito = false;

  bool get esEdicion => widget.vuelo != null;

  // La API programa vuelos según el horario de Ecuador continental (UTC-5).
  DateTime get _ahoraEcuador =>
      DateTime.now().toUtc().subtract(const Duration(hours: 5));

  DateTime get _hoyEcuador {
    final ahora = _ahoraEcuador;
    return DateTime(ahora.year, ahora.month, ahora.day);
  }

  DateTime _sumarDias(DateTime fecha, int dias) =>
      DateTime(fecha.year, fecha.month, fecha.day + dias);

  String _fechaIso(DateTime fecha) =>
      '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

  String _horaTexto(TimeOfDay hora) =>
      '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _horaValida(String valor) {
    final partes = valor.split(':');
    if (partes.length != 2) return null;
    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);
    if (hora == null ||
        minuto == null ||
        hora < 0 ||
        hora > 23 ||
        minuto < 0 ||
        minuto > 59) {
      return null;
    }
    return TimeOfDay(hour: hora, minute: minuto);
  }

  int _minutos(TimeOfDay hora) => hora.hour * 60 + hora.minute;

  bool _salidaFutura(DateTime fecha, TimeOfDay hora) =>
      DateTime.utc(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute)
          .isAfter(_ahoraEcuador);

  @override
  void initState() {
    super.initState();
    aerolineaCtrl =
        TextEditingController(text: widget.vuelo?.aerolinea ?? "AeroAndes");
    origenCtrl = TextEditingController(text: widget.vuelo?.origen ?? "Quito");
    destinoCtrl =
        TextEditingController(text: widget.vuelo?.destino ?? "Guayaquil");
    fechaCtrl = TextEditingController(
        text: widget.vuelo?.fecha ?? _fechaIso(_sumarDias(_hoyEcuador, 1)));
    horaSalidaCtrl = TextEditingController(
        text: widget.vuelo?.horaSalida.substring(0, 5) ?? "08:00");
    horaLlegadaCtrl = TextEditingController(
        text: widget.vuelo?.horaLlegada.substring(0, 5) ?? "09:00");
    precioCtrl =
        TextEditingController(text: widget.vuelo?.precio.toString() ?? "85.00");
    precioEjecutivaCtrl = TextEditingController(
        text: (widget.vuelo?.precioEjecutiva ??
                ((widget.vuelo?.precio ?? 85) * 1.5))
            .toStringAsFixed(2));
    avionId = widget.vuelo?.avionId;
    cargarAviones();
  }

  Future<void> cargarAviones() async {
    setState(() {
      cargandoAviones = true;
      errorAviones = false;
    });
    try {
      final catalogo = await adminVueloService.listarAviones();
      if (mounted) setState(() => aviones = catalogo);
    } catch (_) {
      if (mounted) setState(() => errorAviones = true);
    } finally {
      if (mounted) setState(() => cargandoAviones = false);
    }
  }

  Future<void> guardarVuelo() async {
    setState(() {
      guardando = true;
      mensaje = "";
      exito = false;
    });

    if ([
      aerolineaCtrl,
      origenCtrl,
      destinoCtrl,
      fechaCtrl,
      horaSalidaCtrl,
      horaLlegadaCtrl
    ].any((controller) => controller.text.trim().isEmpty)) {
      setState(() {
        guardando = false;
        mensaje = "Todos los datos del itinerario son obligatorios.";
      });
      return;
    }

    if (origenCtrl.text.trim().toLowerCase() ==
        destinoCtrl.text.trim().toLowerCase()) {
      setState(() {
        guardando = false;
        mensaje = "El origen y el destino deben ser diferentes.";
      });
      return;
    }

    final precio = double.tryParse(precioCtrl.text.trim());
    if (precio == null || precio <= 0) {
      setState(() {
        guardando = false;
        mensaje = "El precio debe ser un número mayor a cero.";
      });
      return;
    }

    if (!esEdicion && avionId == null) {
      setState(() {
        guardando = false;
        mensaje = "Selecciona una aeronave del catálogo.";
      });
      return;
    }
    final tarifaEjecutiva = double.tryParse(precioEjecutivaCtrl.text.trim());
    if (avionId != null &&
        (tarifaEjecutiva == null || tarifaEjecutiva <= precio)) {
      setState(() {
        guardando = false;
        mensaje = "La tarifa ejecutiva debe ser mayor a la tarifa turista.";
      });
      return;
    }

    final fecha = DateTime.tryParse(fechaCtrl.text.trim());
    final salida = _horaValida(horaSalidaCtrl.text.trim());
    final llegada = _horaValida(horaLlegadaCtrl.text.trim());
    final hoy = _hoyEcuador;
    final itinerarioSinCambios = esEdicion &&
        fechaCtrl.text == widget.vuelo!.fecha &&
        horaSalidaCtrl.text == widget.vuelo!.horaSalida.substring(0, 5) &&
        horaLlegadaCtrl.text == widget.vuelo!.horaLlegada.substring(0, 5);
    String? errorItinerario;
    if (fecha == null ||
        _fechaIso(fecha) != fechaCtrl.text.trim() ||
        salida == null ||
        llegada == null) {
      errorItinerario = 'Ingrese una fecha y horarios válidos.';
    } else if (!itinerarioSinCambios) {
      if (fecha.isBefore(hoy) || fecha.isAfter(_sumarDias(hoy, 730))) {
        errorItinerario =
            'La fecha debe estar entre hoy y los próximos 730 días.';
      } else if (!_salidaFutura(fecha, salida)) {
        errorItinerario =
            'La fecha y hora de salida deben ser posteriores a las actuales.';
      } else if (_minutos(llegada) <= _minutos(salida)) {
        errorItinerario =
            'La hora de llegada debe ser posterior a la de salida.';
      }
    }
    if (errorItinerario != null) {
      setState(() {
        guardando = false;
        mensaje = errorItinerario!;
      });
      return;
    }

    try {
      if (esEdicion) {
        await adminVueloService.editarVuelo(
          id: widget.vuelo!.id,
          aerolinea: aerolineaCtrl.text.trim(),
          origen: origenCtrl.text.trim(),
          destino: destinoCtrl.text.trim(),
          fecha: fechaCtrl.text.trim(),
          horaSalida: horaSalidaCtrl.text.trim(),
          horaLlegada: horaLlegadaCtrl.text.trim(),
          precio: double.parse(precioCtrl.text.trim()),
          precioEjecutiva: avionId != null ? tarifaEjecutiva : null,
          avionId: avionId,
        );

        if (!mounted) return;
        Navigator.pop(context, {
          "accion": "editado",
          "origen": origenCtrl.text.trim(),
          "destino": destinoCtrl.text.trim(),
          "fecha": fechaCtrl.text.trim(),
        });
      } else {
        final respuesta = await adminVueloService.crearVuelo(
          aerolinea: aerolineaCtrl.text.trim(),
          origen: origenCtrl.text.trim(),
          destino: destinoCtrl.text.trim(),
          fecha: fechaCtrl.text.trim(),
          horaSalida: horaSalidaCtrl.text.trim(),
          horaLlegada: horaLlegadaCtrl.text.trim(),
          precio: double.parse(precioCtrl.text.trim()),
          precioEjecutiva: tarifaEjecutiva,
          avionId: avionId!,
        );

        final vueloJson = respuesta["vuelo"] as Map<String, dynamic>;
        if (!mounted) return;
        Navigator.pop(context, {
          "accion": "creado",
          "origen": vueloJson["origen"],
          "destino": vueloJson["destino"],
          "fecha": vueloJson["fecha"],
          "id": vueloJson["id"],
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        exito = false;
        mensaje = "Error: $e";
      });
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final hoy = _hoyEcuador;
    final limite = _sumarDias(hoy, 730);
    final actual = DateTime.tryParse(fechaCtrl.text);
    final inicial = actual == null || actual.isBefore(hoy)
        ? hoy
        : actual.isAfter(limite)
            ? limite
            : actual;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: inicial,
      currentDate: hoy,
      firstDate: hoy,
      lastDate: limite,
      helpText: 'Selecciona la fecha del vuelo',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      errorInvalidText: 'La fecha está fuera del rango permitido.',
      errorFormatText: 'Ingrese una fecha válida.',
    );
    if (picked != null && mounted) {
      setState(() {
        fechaCtrl.text = _fechaIso(picked);
        final salida = _horaValida(horaSalidaCtrl.text);
        if (salida != null && !_salidaFutura(picked, salida)) {
          horaSalidaCtrl.clear();
          horaLlegadaCtrl.clear();
          mensaje = 'Selecciona nuevos horarios: la salida anterior ya pasó.';
        } else {
          mensaje = '';
        }
      });
    }
  }

  Future<void> _seleccionarHora(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          _horaValida(controller.text) ?? TimeOfDay.fromDateTime(_ahoraEcuador),
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked == null || !mounted || !context.mounted) return;
    final fecha = DateTime.tryParse(fechaCtrl.text);
    final salida = _horaValida(horaSalidaCtrl.text);
    final llegada = _horaValida(horaLlegadaCtrl.text);
    String? error;
    if (fecha == null || !_salidaFutura(fecha, picked)) {
      error = 'La fecha y hora deben ser posteriores a las actuales.';
    } else if (controller == horaLlegadaCtrl &&
        (salida == null || _minutos(picked) <= _minutos(salida))) {
      error = 'Selecciona primero una salida. La llegada debe ser posterior.';
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() {
      controller.text = _horaTexto(picked);
      mensaje = '';
      if (controller == horaSalidaCtrl &&
          llegada != null &&
          _minutos(llegada) <= _minutos(picked)) {
        horaLlegadaCtrl.clear();
        mensaje = 'Selecciona una nueva hora de llegada posterior a la salida.';
      }
    });
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
    precioEjecutivaCtrl.dispose();
    super.dispose();
  }

  Widget selectorAvion() {
    if (cargandoAviones) {
      return const LinearProgressIndicator(
          semanticsLabel: 'Cargando aeronaves');
    }
    if (errorAviones || aviones.isEmpty) {
      return OutlinedButton.icon(
        onPressed: cargarAviones,
        icon: const Icon(Icons.refresh),
        label: const Text('Reintentar catálogo de aeronaves'),
      );
    }
    final seleccionado =
        aviones.where((avion) => avion.id == avionId).firstOrNull;
    final conReservas = esEdicion &&
        widget.vuelo!.asientosDisponibles < widget.vuelo!.totalAsientos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          initialValue: seleccionado?.id,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Aeronave',
            prefixIcon: Icon(Icons.airplanemode_active, color: AeroColors.navy),
          ),
          hint:
              Text(esEdicion ? 'Conservar cabina actual' : 'Seleccionar avión'),
          items: [
            for (final avion in aviones)
              DropdownMenuItem(
                value: avion.id,
                child: Text('${avion.modelo} · ${avion.capacidad} asientos',
                    overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: guardando || conReservas
              ? null
              : (id) => setState(() => avionId = id),
        ),
        const SizedBox(height: 12),
        if (seleccionado != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AeroColors.ice,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AeroColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${seleccionado.capacidad} asientos en total',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    Text('Ejecutiva: ${seleccionado.ejecutiva}',
                        style: const TextStyle(color: AeroColors.navy)),
                    Text('Turista: ${seleccionado.turista}',
                        style: const TextStyle(color: AeroColors.muted)),
                  ],
                ),
                const SizedBox(height: 16),
                VistaPreviaAvion(
                  key: ValueKey(seleccionado.id),
                  avion: seleccionado,
                ),
              ],
            ),
          )
        else if (esEdicion)
          Text('Capacidad actual: ${widget.vuelo!.totalAsientos} asientos.',
              style: const TextStyle(color: AeroColors.muted)),
        if (conReservas)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('La aeronave se conserva porque existen reservas.',
                style: TextStyle(color: AeroColors.muted)),
          ),
      ],
    );
  }

  Widget campo({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AeroColors.navy),
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
            borderSide: const BorderSide(color: AeroColors.cyan, width: 2),
          ),
        ),
      ),
    );
  }

  Widget campoClickable({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AeroColors.navy),
          suffixIcon: const Icon(Icons.arrow_drop_down),
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
            borderSide: const BorderSide(color: AeroColors.cyan, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.ice,
      appBar: AppBar(
        title: Row(children: [
          const AeroTechLogo(size: 36),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(esEdicion ? "EDITAR VUELO" : "NUEVO VUELO",
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1)),
            const Text("FLYGO · CONTROL DE OPERACIONES",
                style: TextStyle(
                    fontSize: 9, color: AeroColors.cyan, letterSpacing: 1)),
          ]),
        ]),
        elevation: 0,
        backgroundColor: AeroColors.navy,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 780),
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          esEdicion ? Icons.edit_road : Icons.flight_takeoff,
                          size: 32,
                          color: AeroColors.cyan,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(
                          esEdicion
                              ? "Modificar Datos del Vuelo"
                              : "Datos del Vuelo",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AeroColors.navy,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      esEdicion
                          ? "Actualice el itinerario y la aeronave asignada."
                          : "Seleccione la aeronave para generar los asientos de ambas clases automáticamente.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const Divider(height: 32, thickness: 1.2),
                    campo(
                      controller: aerolineaCtrl,
                      label: "Aerolínea",
                      icon: Icons.flight,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]')),
                        LengthLimitingTextInputFormatter(40),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: campo(
                            controller: origenCtrl,
                            label: "Origen",
                            icon: Icons.location_on,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                              LengthLimitingTextInputFormatter(30),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: campo(
                            controller: destinoCtrl,
                            label: "Destino",
                            icon: Icons.place,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                              LengthLimitingTextInputFormatter(30),
                            ],
                          ),
                        ),
                      ],
                    ),
                    campoClickable(
                      controller: fechaCtrl,
                      label: "Fecha del Vuelo",
                      icon: Icons.calendar_month,
                      onTap: () => _seleccionarFecha(context),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: campoClickable(
                            controller: horaSalidaCtrl,
                            label: "Hora Salida",
                            icon: Icons.schedule,
                            onTap: () =>
                                _seleccionarHora(context, horaSalidaCtrl),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: campoClickable(
                            controller: horaLlegadaCtrl,
                            label: "Hora Llegada",
                            icon: Icons.access_time,
                            onTap: () =>
                                _seleccionarHora(context, horaLlegadaCtrl),
                          ),
                        ),
                      ],
                    ),
                    campo(
                      controller: precioCtrl,
                      label: "Tarifa turista (USD)",
                      icon: Icons.attach_money,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    selectorAvion(),
                    if (avionId != null) ...[
                      const SizedBox(height: 16),
                      campo(
                        controller: precioEjecutivaCtrl,
                        label: "Tarifa ejecutiva (USD)",
                        icon: Icons.airline_seat_recline_extra,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AeroColors.cyan,
                          foregroundColor: AeroColors.navy,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: guardando ||
                                cargandoAviones ||
                                errorAviones ||
                                (!esEdicion && avionId == null)
                            ? null
                            : guardarVuelo,
                        icon: guardando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(esEdicion ? Icons.save : Icons.add_circle),
                        label: Text(
                          guardando
                              ? "Guardando..."
                              : (esEdicion
                                  ? "Guardar Cambios"
                                  : "Registrar Vuelo"),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (mensaje.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              exito ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: exito
                                ? Colors.green.shade300
                                : Colors.red.shade300,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              exito ? Icons.check_circle : Icons.error,
                              color: exito
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mensaje,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: exito
                                      ? Colors.green.shade900
                                      : Colors.red.shade900,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
