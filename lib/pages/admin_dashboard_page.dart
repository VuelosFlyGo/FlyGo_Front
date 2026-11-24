import 'package:flutter/material.dart';

import '../models/admin_dashboard.dart';
import '../services/admin_vuelo_service.dart';
import '../services/servidor_no_disponible_exception.dart';
import '../theme/aerotech_theme.dart';
import '../widgets/aerotech_logo.dart';
import '../widgets/servidor_no_disponible_panel.dart';

class AdminDashboardPage extends StatefulWidget {
  final AdminDashboardData? initialData;

  const AdminDashboardPage({super.key, this.initialData});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _service = AdminVueloService();
  AdminDashboardData? _data;
  bool _cargando = true;
  bool _servidorNoDisponible = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _cargando = false;
    } else {
      _cargar();
    }
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = '';
      _servidorNoDisponible = false;
    });
    try {
      final data = await _service.obtenerDashboard();
      if (!mounted) return;
      setState(() => _data = data);
    } on ServidorNoDisponibleException {
      if (mounted) setState(() => _servidorNoDisponible = true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AeroColors.ice,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AeroColors.navy,
          title: const Row(
            children: [
              AeroTechLogo(size: 34, light: false),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CONTROL DE OPERACIONES',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .7)),
                    Text('Dashboard administrativo',
                        style: TextStyle(
                            fontSize: 10,
                            color: AeroColors.blue,
                            letterSpacing: .5)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _cargando ? null : _cargar,
              tooltip: 'Actualizar datos',
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            labelColor: AeroColors.blue,
            unselectedLabelColor: AeroColors.muted,
            indicatorColor: AeroColors.blue,
            tabs: [
              Tab(icon: Icon(Icons.space_dashboard_outlined), text: 'Resumen'),
              Tab(icon: Icon(Icons.history_outlined), text: 'Auditoría'),
            ],
          ),
        ),
        body: _contenido(),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando && _data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_servidorNoDisponible) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ServidorNoDisponiblePanel(onReintentar: _cargar),
          ),
        ),
      );
    }
    if (_error.isNotEmpty || _data == null) {
      return _EstadoVacio(
        icon: Icons.warning_amber_rounded,
        titulo: 'No pudimos cargar el panel',
        detalle: _error,
        onReintentar: _cargar,
      );
    }
    return TabBarView(
      children: [
        _ResumenTab(data: _data!, onActualizar: _cargar),
        _AuditoriaTab(vuelos: _data!.auditoria, onActualizar: _cargar),
      ],
    );
  }
}

class _ResumenTab extends StatelessWidget {
  final AdminDashboardData data;
  final Future<void> Function() onActualizar;

  const _ResumenTab({required this.data, required this.onActualizar});

  @override
  Widget build(BuildContext context) {
    final resumen = data.resumen;
    return RefreshIndicator(
      onRefresh: onActualizar,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Estado de la red',
              style: TextStyle(
                  color: AeroColors.ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            'Una lectura rápida de vuelos, capacidad y actividad comercial.',
            style: TextStyle(color: AeroColors.muted),
          ),
          const SizedBox(height: 18),
          _OperationsBand(resumen: resumen),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 850;
              final salidas = _ProximasSalidas(vuelos: data.proximosVuelos);
              final actividad = _ActividadComercial(resumen: resumen);
              if (compact) {
                return Column(
                    children: [salidas, const SizedBox(height: 16), actividad]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: salidas),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: actividad),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OperationsBand extends StatelessWidget {
  final AdminResumen resumen;
  const _OperationsBand({required this.resumen});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.flight_takeoff,
        'Vigentes',
        resumen.vuelosVigentes,
        AeroColors.emerald
      ),
      (
        Icons.flag_outlined,
        'Finalizados',
        resumen.vuelosFinalizados,
        AeroColors.blue
      ),
      (
        Icons.event_seat_outlined,
        'Asientos libres',
        resumen.asientosDisponibles,
        Colors.orange.shade700
      ),
      (
        Icons.person_outline,
        'Clientes',
        resumen.clientesActivos,
        AeroColors.cyan
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.line),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth < 480
              ? constraints.maxWidth
              : constraints.maxWidth < 720
                  ? constraints.maxWidth / 2
                  : constraints.maxWidth / 4;
          return Wrap(
            children: items
                .map((item) => SizedBox(
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: item.$4.withValues(alpha: .11),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(item.$1, color: item.$4, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item.$3}',
                                    style: const TextStyle(
                                        color: AeroColors.ink,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800)),
                                Text(item.$2,
                                    style: const TextStyle(
                                        color: AeroColors.muted, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class _ProximasSalidas extends StatelessWidget {
  final List<AdminVueloResumen> vuelos;
  const _ProximasSalidas({required this.vuelos});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Text('Próximas salidas',
                style: TextStyle(
                    color: AeroColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
          ),
          if (vuelos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text('No existen vuelos próximos programados.',
                  style: TextStyle(color: AeroColors.muted)),
            )
          else
            ...vuelos.map((vuelo) => _SalidaRow(vuelo: vuelo)),
        ],
      ),
    );
  }
}

class _SalidaRow extends StatelessWidget {
  final AdminVueloResumen vuelo;
  const _SalidaRow({required this.vuelo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AeroColors.line)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flight, color: AeroColors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${vuelo.origen} → ${vuelo.destino}',
                    style: const TextStyle(
                        color: AeroColors.ink, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('${vuelo.aerolinea} · ${vuelo.fecha}',
                    style:
                        const TextStyle(color: AeroColors.muted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(vuelo.horaSalida.substring(0, 5),
                  style: const TextStyle(
                      color: AeroColors.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
              Text('${vuelo.asientosDisponibles} asientos',
                  style:
                      const TextStyle(color: AeroColors.emerald, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActividadComercial extends StatelessWidget {
  final AdminResumen resumen;
  const _ActividadComercial({required this.resumen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AeroColors.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.assessment_outlined, color: AeroColors.cyan),
          const SizedBox(height: 16),
          const Text('Actividad de reservas',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          _dato('Reservas activas', '${resumen.reservasActivas}'),
          _dato('Pasajeros confirmados', '${resumen.pasajerosConfirmados}'),
          _dato('Ingresos confirmados',
              '\$${resumen.ingresosConfirmados.toStringAsFixed(2)}'),
          _dato('Vuelos desactivados', '${resumen.vuelosInactivos}',
              ultimo: true),
        ],
      ),
    );
  }

  Widget _dato(String label, String value, {bool ultimo = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: ultimo
              ? null
              : Border(
                  bottom:
                      BorderSide(color: Colors.white.withValues(alpha: .12))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(color: Colors.white.withValues(alpha: .7))),
            ),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
          ],
        ),
      );
}

class _AuditoriaTab extends StatelessWidget {
  final List<AdminVueloAuditoria> vuelos;
  final Future<void> Function() onActualizar;

  const _AuditoriaTab({required this.vuelos, required this.onActualizar});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onActualizar,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vuelos desactivados',
                        style: TextStyle(
                            color: AeroColors.ink,
                            fontSize: 25,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 6),
                    Text(
                      'Evidencia conservada mediante borrado lógico.',
                      style: TextStyle(color: AeroColors.muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AeroColors.coral.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${vuelos.length} registros',
                    style: const TextStyle(
                        color: AeroColors.coral, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (vuelos.isEmpty)
            const _EstadoVacio(
              icon: Icons.fact_check_outlined,
              titulo: 'Sin vuelos desactivados',
              detalle: 'Las futuras desactivaciones quedarán registradas aquí.',
            )
          else
            ...vuelos.map((vuelo) => _AuditoriaRow(vuelo: vuelo)),
        ],
      ),
    );
  }
}

class _AuditoriaRow extends StatelessWidget {
  final AdminVueloAuditoria vuelo;
  const _AuditoriaRow({required this.vuelo});

  @override
  Widget build(BuildContext context) {
    final fechaRegistro = _formatearFecha(vuelo.fechaDesactivacion);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AeroColors.line),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;
          final ruta = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${vuelo.origen} → ${vuelo.destino}',
                  style: const TextStyle(
                      color: AeroColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${vuelo.aerolinea} · Vuelo #${vuelo.id}',
                  style:
                      const TextStyle(color: AeroColors.muted, fontSize: 12)),
            ],
          );
          final datos = Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _meta(Icons.event_outlined, 'Salida',
                  '${vuelo.fecha} ${vuelo.horaSalida.substring(0, 5)}'),
              _meta(Icons.history, 'Desactivado', fechaRegistro),
              _meta(Icons.confirmation_number_outlined, 'Reservas',
                  '${vuelo.reservasRelacionadas}'),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ruta,
                const SizedBox(height: 14),
                _metaCompact(Icons.event_outlined, 'Salida',
                    '${vuelo.fecha} ${vuelo.horaSalida.substring(0, 5)}'),
                const SizedBox(height: 8),
                _metaCompact(Icons.history, 'Desactivado', fechaRegistro),
                const SizedBox(height: 8),
                _metaCompact(Icons.confirmation_number_outlined, 'Reservas',
                    '${vuelo.reservasRelacionadas}'),
              ],
            );
          }
          return Row(
            children: [
              Expanded(flex: 3, child: ruta),
              Expanded(flex: 5, child: datos),
              const Chip(label: Text('INACTIVO')),
            ],
          );
        },
      ),
    );
  }

  Widget _meta(IconData icon, String label, String value) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AeroColors.blue),
          const SizedBox(width: 6),
          Text('$label: ',
              style: const TextStyle(color: AeroColors.muted, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: AeroColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ],
      );

  Widget _metaCompact(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AeroColors.blue),
          const SizedBox(width: 6),
          Text('$label: ',
              style: const TextStyle(color: AeroColors.muted, fontSize: 12)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AeroColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      );

  String _formatearFecha(String? value) {
    if (value == null) return 'Registro anterior';
    final fecha = DateTime.tryParse(value)?.toLocal();
    if (fecha == null) return value;
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} ${dos(fecha.hour)}:${dos(fecha.minute)}';
  }
}

class _EstadoVacio extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String detalle;
  final VoidCallback? onReintentar;

  const _EstadoVacio({
    required this.icon,
    required this.titulo,
    required this.detalle,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AeroColors.blue, size: 44),
            const SizedBox(height: 12),
            Text(titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AeroColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(detalle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AeroColors.muted)),
            if (onReintentar != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
