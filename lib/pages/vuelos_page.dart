import 'dart:async';

import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/vuelo.dart';
import '../services/vuelos_service.dart';
import '../services/admin_vuelo_service.dart';
import '../widgets/vuelo_card.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../services/servidor_no_disponible_exception.dart';
import '../theme/aerotech_theme.dart';
import '../widgets/aerotech_logo.dart';
import '../widgets/servidor_no_disponible_panel.dart';
import '../utils/navigation_observer.dart';
import 'login_page.dart';
import 'reservas_page.dart';
import 'seleccion_asientos_page.dart';
import 'crear_vuelo_page.dart';
import 'admin_dashboard_page.dart';

class VuelosPage extends StatefulWidget {
  const VuelosPage({super.key});

  @override
  State<VuelosPage> createState() => _VuelosPageState();
}

class _VuelosPageState extends State<VuelosPage> with RouteAware {
  final origenCtrl = TextEditingController();
  final destinoCtrl = TextEditingController();
  final fechaInicioCtrl = TextEditingController();
  final fechaFinCtrl = TextEditingController();

  final VuelosService vuelosService = VuelosService();

  List<Vuelo> vuelos = [];
  List<Vuelo> catalogo = [];
  bool cargando = false;
  Completer<void>? _actualizacionActiva;
  Timer? _temporizadorActualizacion;
  bool _rutaVisible = true;
  String mensaje = "";
  bool servidorNoDisponible = false;

  bool get esAdmin => ApiConfig.rol == "admin";

  String get nombreSesion {
    final usuario = ApiConfig.usuario.trim();
    if (usuario.isEmpty) return 'Viajero';
    return '${usuario[0].toUpperCase()}${usuario.substring(1)}';
  }

  String _firmaVuelos(List<Vuelo> lista) => lista
      .map((v) => '${v.id}:${v.precio}:${v.asientosDisponibles}')
      .join('|');

  Future<void> buscar({bool silencioso = false}) async {
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
        servidorNoDisponible = false;
      });
    }

    try {
      final filtrosActivos = [
        origenCtrl,
        destinoCtrl,
        fechaInicioCtrl,
        fechaFinCtrl
      ].any((c) => c.text.trim().isNotEmpty);
      final catalogoActual = await vuelosService.buscarVuelos();
      final data = filtrosActivos
          ? await vuelosService.buscarVuelos(
              origen: origenCtrl.text.trim(),
              destino: destinoCtrl.text.trim(),
              fechaInicio: fechaInicioCtrl.text.trim(),
              fechaFin: fechaFinCtrl.text.trim(),
            )
          : catalogoActual;

      if (!mounted) return;
      final idsAnteriores = catalogo.map((v) => v.id).toSet();
      final nuevosVuelos =
          catalogoActual.where((v) => !idsAnteriores.contains(v.id)).toList();
      final cambioResultados = silencioso &&
          vuelos.isNotEmpty &&
          _firmaVuelos(vuelos) != _firmaVuelos(data);
      final mensajeCambio = nuevosVuelos.isNotEmpty && catalogo.isNotEmpty
          ? "Se publicó ${nuevosVuelos.length == 1 ? 'un nuevo vuelo' : '${nuevosVuelos.length} nuevos vuelos'}. El catálogo y los filtros ya fueron actualizados."
          : "La disponibilidad o tarifa de los vuelos cambió. La lista ya fue actualizada con los datos más recientes.";
      setState(() {
        vuelos = data;
        catalogo = catalogoActual;
        servidorNoDisponible = false;
      });
      if (silencioso &&
          _rutaVisible &&
          (cambioResultados ||
              (nuevosVuelos.isNotEmpty && idsAnteriores.isNotEmpty))) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(mensajeCambio),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } on SesionExpiradaException {
      return;
    } on ServidorNoDisponibleException {
      if (mounted) {
        setState(() {
          servidorNoDisponible = true;
          mensaje = '';
        });
      }
    } catch (e) {
      if (!silencioso && mounted) {
        setState(() {
          mensaje = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      ciclo.complete();
      if (identical(_actualizacionActiva, ciclo)) _actualizacionActiva = null;
      if (!silencioso && mounted) setState(() => cargando = false);
    }
  }

  Future<void> _seleccionarFechaInicio(BuildContext context) async {
    final hoy = DateUtils.dateOnly(DateTime.now());
    final dateFin = DateTime.tryParse(fechaFinCtrl.text) ??
        DateTime.now().add(const Duration(days: 365 * 2));
    final limiteFin = dateFin.isBefore(hoy) ? hoy : dateFin;
    final candidata = DateTime.tryParse(fechaInicioCtrl.text) ?? hoy;
    final initial = candidata.isBefore(hoy)
        ? hoy
        : (candidata.isAfter(limiteFin) ? limiteFin : candidata);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: hoy,
      lastDate: limiteFin,
    );
    if (picked != null) {
      setState(() {
        fechaInicioCtrl.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _seleccionarFechaFin(BuildContext context) async {
    final hoy = DateUtils.dateOnly(DateTime.now());
    final fechaInicio = DateTime.tryParse(fechaInicioCtrl.text) ?? hoy;
    final dateInicio = fechaInicio.isBefore(hoy) ? hoy : fechaInicio;
    final ultimoDia = DateTime.now().add(const Duration(days: 365 * 2));
    final candidata = DateTime.tryParse(fechaFinCtrl.text) ?? dateInicio;
    final initial = candidata.isBefore(dateInicio)
        ? dateInicio
        : (candidata.isAfter(ultimoDia) ? ultimoDia : candidata);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: dateInicio,
      lastDate: ultimoDia,
    );
    if (picked != null) {
      setState(() {
        fechaFinCtrl.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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

  void abrirFormularioVuelo([Vuelo? vuelo]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CrearVueloPage(vuelo: vuelo),
      ),
    ).then((resultado) {
      if (!mounted) return;
      if (resultado is Map) {
        final fecha = resultado["fecha"]?.toString();
        origenCtrl.text = resultado["origen"]?.toString() ?? origenCtrl.text;
        destinoCtrl.text = resultado["destino"]?.toString() ?? destinoCtrl.text;
        if (fecha != null && fecha.isNotEmpty) {
          fechaInicioCtrl.text = fecha;
          fechaFinCtrl.text = fecha;
        }
        final accion =
            resultado["accion"] == "creado" ? "creado" : "actualizado";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Vuelo $accion correctamente. Ya aparece en el panel."),
          backgroundColor: AeroColors.emerald,
          behavior: SnackBarBehavior.floating,
        ));
      }
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
            Text("Desactivar vuelo"),
          ],
        ),
        content: Text(
            "¿Desea desactivar el vuelo de ${vuelo.origen} a ${vuelo.destino} con ${vuelo.aerolinea}? Dejará de mostrarse a los clientes, pero permanecerá en el historial administrativo."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text("Cancelar", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Desactivar"),
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
            content: const Text(
                "Vuelo desactivado. Se conserva en el historial administrativo."),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        buscar();
      } on ConflictoConcurrenciaException catch (e) {
        await buscar(silencioso: true);
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
            content: Text(
                "Error al desactivar vuelo: ${e.toString().replaceAll('Exception: ', '')}"),
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
    _iniciarActualizacionAutomatica();
  }

  void _iniciarActualizacionAutomatica() {
    _temporizadorActualizacion?.cancel();
    _temporizadorActualizacion = Timer.periodic(
      const Duration(seconds: 6),
      (_) => buscar(silencioso: true),
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
    buscar(silencioso: true);
    _iniciarActualizacionAutomatica();
  }

  @override
  void dispose() {
    flyGoRouteObserver.unsubscribe(this);
    _temporizadorActualizacion?.cancel();
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
        prefixIcon: Icon(icon, color: AeroColors.navy, size: 20),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget selectorCiudad({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> opciones,
  }) {
    final actual = opciones.contains(controller.text) ? controller.text : null;
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-${controller.text}-${opciones.length}'),
      initialValue: actual,
      isExpanded: true,
      decoration: InputDecoration(
          labelText: label, prefixIcon: Icon(icon, color: AeroColors.blue)),
      hint: Text(opciones.isEmpty ? 'Sin opciones disponibles' : 'Todos'),
      items: [
        const DropdownMenuItem(value: '', child: Text('Todos')),
        ...opciones.map(
            (ciudad) => DropdownMenuItem(value: ciudad, child: Text(ciudad))),
      ],
      onChanged: (value) => setState(() => controller.text = value ?? ''),
    );
  }

  void limpiarFiltros() {
    setState(() {
      origenCtrl.clear();
      destinoCtrl.clear();
      fechaInicioCtrl.clear();
      fechaFinCtrl.clear();
    });
    buscar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.ice,
      appBar: AppBar(
        title: Row(
          children: [
            const AeroTechLogo(size: 36, light: false),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('FLYGO',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                          color: AeroColors.navy)),
                  Text(
                      esAdmin
                          ? 'ADMINISTRACIÓN DE VUELOS'
                          : 'ENCUENTRA TU PRÓXIMO DESTINO',
                      style: const TextStyle(
                          fontSize: 9,
                          color: AeroColors.blue,
                          letterSpacing: 1.1)),
                ])),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AeroColors.navy,
        actions: [
          if (esAdmin)
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminDashboardPage(),
                ),
              ),
              icon: const Icon(Icons.space_dashboard_outlined),
              tooltip: 'Dashboard y auditoría',
            ),
          if (!esAdmin)
            IconButton(
              onPressed: abrirMisReservas,
              icon: const Icon(Icons.confirmation_number_outlined),
              tooltip: "Mis reservas",
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
            decoration: const BoxDecoration(
              color: AeroColors.ice,
              border: Border(bottom: BorderSide(color: AeroColors.line)),
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AeroColors.blue.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: AeroColors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenido, $nombreSesion',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AeroColors.ink,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                esAdmin
                                    ? 'Sesión de administrador'
                                    : 'Tu sesión está activa',
                                style: const TextStyle(
                                  color: AeroColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (esAdmin) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Red de vuelos",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Gestiona rutas, horarios, tarifas y disponibilidad desde un solo panel.",
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => abrirFormularioVuelo(),
                            icon: const Icon(Icons.add),
                            label: const Text("Crear vuelo"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Busca entre los destinos disponibles',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AeroColors.ink))),
                    const SizedBox(height: 6),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Puedes ver todos los vuelos o filtrar usando únicamente ciudades que existen en el sistema.',
                            style: TextStyle(color: AeroColors.muted))),
                    const SizedBox(height: 18),
                    LayoutBuilder(builder: (context, constraints) {
                      final compact = constraints.maxWidth < 590;
                      final origenes = catalogo
                          .map((v) => v.origen)
                          .toSet()
                          .toList()
                        ..sort();
                      final destinos = catalogo
                          .map((v) => v.destino)
                          .toSet()
                          .toList()
                        ..sort();
                      final origin = selectorCiudad(
                          controller: origenCtrl,
                          label: "Desde",
                          icon: Icons.flight_takeoff,
                          opciones: origenes);
                      final destination = selectorCiudad(
                          controller: destinoCtrl,
                          label: "Hacia",
                          icon: Icons.flight_land,
                          opciones: destinos);
                      if (compact) {
                        return Column(children: [
                          origin,
                          const SizedBox(height: 12),
                          destination
                        ]);
                      }
                      return Row(children: [
                        Expanded(child: origin),
                        const SizedBox(width: 12),
                        Expanded(child: destination)
                      ]);
                    }),
                    const SizedBox(height: 12),
                    // Date range selection controls
                    LayoutBuilder(builder: (context, constraints) {
                      final compact = constraints.maxWidth < 590;
                      final start = inputField(
                          controller: fechaInicioCtrl,
                          label: "Salida desde",
                          icon: Icons.calendar_month,
                          readOnly: true,
                          onTap: () => _seleccionarFechaInicio(context));
                      final end = inputField(
                          controller: fechaFinCtrl,
                          label: "Salida hasta",
                          icon: Icons.event_available,
                          readOnly: true,
                          onTap: () => _seleccionarFechaFin(context));
                      if (compact) {
                        return Column(
                            children: [start, const SizedBox(height: 12), end]);
                      }
                      return Row(children: [
                        Expanded(child: start),
                        const SizedBox(width: 12),
                        Expanded(child: end)
                      ]);
                    }),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AeroColors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 1,
                                ),
                                onPressed: cargando ? null : buscar,
                                icon: const Icon(Icons.search, size: 20),
                                label: Text(
                                  cargando
                                      ? "Consultando red..."
                                      : "Consultar vuelos",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ))),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                          onPressed: cargando ? null : limpiarFiltros,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Ver todos')),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!cargando && mensaje.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
              child: Row(children: [
                const Expanded(
                    child: Text('Vuelos disponibles',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AeroColors.ink))),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: AeroColors.blue.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('${vuelos.length} opciones',
                        style: const TextStyle(
                            color: AeroColors.blue,
                            fontWeight: FontWeight.w700))),
              ]),
            ),
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

          if (servidorNoDisponible)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: ServidorNoDisponiblePanel(
                onReintentar: buscar,
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
                            const Icon(Icons.radar,
                                size: 60, color: AeroColors.cyan),
                            const SizedBox(height: 12),
                            Text(
                              "No hay vuelos para esta ruta y fechas.",
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: vuelos.length,
                        itemBuilder: (context, index) {
                          final vuelo = vuelos[index];
                          return VueloCard(
                            vuelo: vuelo,
                            onReservar: () => abrirSeleccionAsientos(vuelo),
                            onEditar: esAdmin
                                ? () => abrirFormularioVuelo(vuelo)
                                : null,
                            onEliminar: esAdmin
                                ? () => confirmarEliminacion(vuelo)
                                : null,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
