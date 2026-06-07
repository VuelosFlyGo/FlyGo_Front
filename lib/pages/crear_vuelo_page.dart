import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vuelo.dart';
import '../services/admin_vuelo_service.dart';

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
  late final TextEditingController cantidadAsientosCtrl;

  final AdminVueloService adminVueloService = AdminVueloService();

  bool guardando = false;
  String mensaje = "";
  bool exito = false;

  bool get esEdicion => widget.vuelo != null;

  @override
  void initState() {
    super.initState();
    aerolineaCtrl = TextEditingController(text: widget.vuelo?.aerolinea ?? "AeroAndes");
    origenCtrl = TextEditingController(text: widget.vuelo?.origen ?? "Quito");
    destinoCtrl = TextEditingController(text: widget.vuelo?.destino ?? "Guayaquil");
    fechaCtrl = TextEditingController(text: widget.vuelo?.fecha ?? "2026-06-20");
    horaSalidaCtrl = TextEditingController(text: widget.vuelo?.horaSalida.substring(0, 5) ?? "08:00");
    horaLlegadaCtrl = TextEditingController(text: widget.vuelo?.horaLlegada.substring(0, 5) ?? "09:00");
    precioCtrl = TextEditingController(text: widget.vuelo?.precio.toString() ?? "85.00");
    cantidadAsientosCtrl = TextEditingController(text: widget.vuelo?.asientosDisponibles.toString() ?? "12");
  }

  Future<void> guardarVuelo() async {
    setState(() {
      guardando = true;
      mensaje = "";
      exito = false;
    });

    // Validations
    final precio = double.tryParse(precioCtrl.text.trim());
    if (precio == null || precio <= 0) {
      setState(() {
        guardando = false;
        mensaje = "El precio debe ser un número mayor a cero.";
      });
      return;
    }

    final asientos = int.tryParse(cantidadAsientosCtrl.text.trim());
    if (asientos == null || asientos <= 0) {
      setState(() {
        guardando = false;
        mensaje = "La cantidad de asientos debe ser mayor a cero.";
      });
      return;
    }

    final date = DateTime.tryParse(fechaCtrl.text.trim());
    if (date != null) {
      final now = DateTime.now();
      if (DateUtils.isSameDay(date, now)) {
        final timeParts = horaSalidaCtrl.text.trim().split(":");
        if (timeParts.length == 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          final departureDateTime = DateTime(date.year, date.month, date.day, hour, minute);
          if (departureDateTime.isBefore(now)) {
            setState(() {
              guardando = false;
              mensaje = "La hora de salida no puede ser anterior a la hora actual.";
            });
            return;
          }
        }
      }
    }

    final timePartsSalida = horaSalidaCtrl.text.trim().split(":");
    final timePartsLlegada = horaLlegadaCtrl.text.trim().split(":");
    if (timePartsSalida.length == 2 && timePartsLlegada.length == 2) {
      final hourSalida = int.tryParse(timePartsSalida[0]) ?? 0;
      final minuteSalida = int.tryParse(timePartsSalida[1]) ?? 0;
      final hourLlegada = int.tryParse(timePartsLlegada[0]) ?? 0;
      final minuteLlegada = int.tryParse(timePartsLlegada[1]) ?? 0;
      
      final minutosSalida = hourSalida * 60 + minuteSalida;
      final minutosLlegada = hourLlegada * 60 + minuteLlegada;
      
      if (minutosLlegada <= minutosSalida) {
        setState(() {
          guardando = false;
          mensaje = "La hora de llegada debe ser posterior a la hora de salida.";
        });
        return;
      }
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
        );

        setState(() {
          exito = true;
          mensaje = "Vuelo actualizado correctamente.";
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
          cantidadAsientos: int.parse(cantidadAsientosCtrl.text.trim()),
        );

        final vueloJson = respuesta["vuelo"];

        setState(() {
          exito = true;
          mensaje =
              "Vuelo creado correctamente\n"
              "ID: ${vueloJson["id"]}\n"
              "Asientos generados: ${vueloJson["asientos_generados"].join(", ")}";
        });
      }
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

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(fechaCtrl.text) ?? DateTime.now(),
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        fechaCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _seleccionarHora(BuildContext context, TextEditingController controller) async {
    final parts = controller.text.split(":");
    final initialHour = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 8) : 8;
    final initialMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );
    if (picked != null) {
      final date = DateTime.tryParse(fechaCtrl.text.trim());
      if (date != null) {
        final now = DateTime.now();
        if (DateUtils.isSameDay(date, now)) {
          final selectedTime = DateTime(date.year, date.month, date.day, picked.hour, picked.minute);
          if (selectedTime.isBefore(now)) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("La hora no puede ser anterior a la hora actual."),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
        }
      }

      if (controller == horaLlegadaCtrl) {
        final timePartsSalida = horaSalidaCtrl.text.trim().split(":");
        if (timePartsSalida.length == 2) {
          final hourSalida = int.tryParse(timePartsSalida[0]) ?? 0;
          final minuteSalida = int.tryParse(timePartsSalida[1]) ?? 0;
          final minsSalida = hourSalida * 60 + minuteSalida;
          final minsLlegada = picked.hour * 60 + picked.minute;
          if (minsLlegada <= minsSalida) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("La hora de llegada debe ser posterior a la de salida."),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
        }
      }

      setState(() {
        controller.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
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
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
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
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
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
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(esEdicion ? "Editar Vuelo" : "Registrar Vuelo"),
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
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black12,
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
                          color: Colors.blue.shade800,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          esEdicion ? "Modificar Datos del Vuelo" : "Datos del Vuelo",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      esEdicion
                          ? "Actualice los detalles del vuelo. Los asientos y las reservas existentes no se alterarán."
                          : "Ingrese la información para el nuevo itinerario. El sistema creará los asientos automáticamente.",
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
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]')),
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
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
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
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
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
                            onTap: () => _seleccionarHora(context, horaSalidaCtrl),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: campoClickable(
                            controller: horaLlegadaCtrl,
                            label: "Hora Llegada",
                            icon: Icons.access_time,
                            onTap: () => _seleccionarHora(context, horaLlegadaCtrl),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: campo(
                            controller: precioCtrl,
                            label: "Precio (USD)",
                            icon: Icons.attach_money,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                          ),
                        ),
                        if (!esEdicion) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: campo(
                              controller: cantidadAsientosCtrl,
                              label: "Capacidad Asientos",
                              icon: Icons.event_seat,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: guardando ? null : guardarVuelo,
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
                              : (esEdicion ? "Guardar Cambios" : "Registrar Vuelo"),
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
                          color: exito ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: exito ? Colors.green.shade300 : Colors.red.shade300,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              exito ? Icons.check_circle : Icons.error,
                              color: exito ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mensaje,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: exito ? Colors.green.shade900 : Colors.red.shade900,
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