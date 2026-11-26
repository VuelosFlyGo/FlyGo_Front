import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/vuelo.dart';
import '../theme/aerotech_theme.dart';

class VueloCard extends StatelessWidget {
  final Vuelo vuelo;
  final VoidCallback onReservar;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const VueloCard({
    super.key,
    required this.vuelo,
    required this.onReservar,
    this.onEditar,
    this.onEliminar,
  });

  bool get _esAdmin => ApiConfig.rol == 'admin';
  bool get _vigente => vuelo.situacion == 'VIGENTE' && vuelo.estado;
  String _dinero(double precio) => '\$${precio.toStringAsFixed(2)}';

  String get _fecha {
    final fecha = DateTime.tryParse(vuelo.fecha);
    if (fecha == null) return vuelo.fecha;
    const meses = [
      'ene.',
      'feb.',
      'mar.',
      'abr.',
      'may.',
      'jun.',
      'jul.',
      'ago.',
      'sep.',
      'oct.',
      'nov.',
      'dic.'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  String get _duracion {
    final horas = vuelo.duracion.inHours;
    final minutos = vuelo.duracion.inMinutes.remainder(60);
    return '${horas}h ${minutos.toString().padLeft(2, '0')}min';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AeroColors.line),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compacto = constraints.maxWidth < 680;
          final detalle = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _encabezado(),
              const SizedBox(height: 18),
              _ruta(),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AeroColors.line),
              const SizedBox(height: 12),
              _tarifas(),
              if (_esAdmin) ...[
                const SizedBox(height: 12),
                _ocupacion(),
              ],
            ],
          );
          final acciones = _acciones(compacto);
          if (compacto) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                detalle,
                const SizedBox(height: 14),
                const Divider(height: 1, color: AeroColors.line),
                const SizedBox(height: 12),
                acciones,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: detalle),
              const SizedBox(width: 24),
              Container(width: 1, height: 156, color: AeroColors.line),
              const SizedBox(width: 24),
              SizedBox(width: 214, child: acciones),
            ],
          );
        },
      ),
    );
  }

  Widget _encabezado() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AeroColors.blue.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.flight_takeoff,
              color: AeroColors.blue, size: 21),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vuelo.aerolinea,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AeroColors.ink,
                      fontSize: 15)),
              Text(
                  [
                    if (vuelo.avionModelo != null) vuelo.avionModelo!,
                    _fecha,
                  ].join(' · '),
                  style:
                      const TextStyle(color: AeroColors.muted, fontSize: 12)),
            ],
          ),
        ),
        if (_esAdmin || !_vigente) _EstadoVuelo(vuelo: vuelo),
      ],
    );
  }

  Widget _ruta() => Row(
        children: [
          Expanded(child: _extremo(vuelo.origen, vuelo.horaSalida, false)),
          Expanded(
            child: Column(
              children: [
                Text(_duracion,
                    style: const TextStyle(
                        color: AeroColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Row(children: [
                  Expanded(
                      child: Divider(color: AeroColors.line, thickness: 2)),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: RotatedBox(
                          quarterTurns: 1,
                          child: Icon(Icons.flight,
                              size: 21, color: AeroColors.blue))),
                  Expanded(
                      child: Divider(color: AeroColors.line, thickness: 2)),
                ]),
                const SizedBox(height: 4),
                const Text('Vuelo directo',
                    style: TextStyle(color: AeroColors.muted, fontSize: 11)),
              ],
            ),
          ),
          Expanded(child: _extremo(vuelo.destino, vuelo.horaLlegada, true)),
        ],
      );

  Widget _extremo(String ciudad, String hora, bool derecho) => Column(
        crossAxisAlignment:
            derecho ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(hora.substring(0, 5),
              style: const TextStyle(
                  fontSize: 25,
                  height: 1.1,
                  color: AeroColors.navy,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(ciudad,
              textAlign: derecho ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                  color: AeroColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      );

  Widget _tarifas() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _TarifaClase(
              nombre: 'Turista',
              precio: _dinero(vuelo.precio),
              cupos: vuelo.turistaDisponibles,
              ejecutiva: false),
          if (vuelo.precioEjecutiva != null)
            _TarifaClase(
                nombre: 'Ejecutiva',
                precio: _dinero(vuelo.precioEjecutiva!),
                cupos: vuelo.ejecutivaDisponibles,
                ejecutiva: true),
        ],
      );

  Widget _ocupacion() {
    final total = vuelo.totalAsientos > vuelo.asientosDisponibles
        ? vuelo.totalAsientos
        : vuelo.asientosDisponibles;
    final ocupados = (total - vuelo.asientosDisponibles).clamp(0, total);
    final proporcion = total > 0 ? ocupados / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Expanded(
              child: Text('Ocupación',
                  style: TextStyle(color: AeroColors.muted, fontSize: 12))),
          Text('$ocupados/$total asientos · ${(proporcion * 100).round()}%',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AeroColors.navy)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
              value: proporcion,
              minHeight: 6,
              backgroundColor: AeroColors.line,
              color: AeroColors.blue),
        ),
      ],
    );
  }

  Widget _acciones(bool compacto) {
    if (_esAdmin) {
      if (!vuelo.estado || vuelo.situacion == 'INACTIVO') {
        return const Text('Vuelo inactivo',
            textAlign: TextAlign.center,
            style: TextStyle(color: AeroColors.muted));
      }
      final editar = OutlinedButton.icon(
          onPressed: onEditar,
          icon: const Icon(Icons.edit_outlined, size: 17),
          label: const Text('Editar vuelo'));
      final desactivar = TextButton.icon(
          onPressed: vuelo.reservasActivas > 0 ? null : onEliminar,
          style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
          icon: const Icon(Icons.delete_outline, size: 17),
          label: const Text('Desactivar'));
      final avisoReservas = Text(
        'No se puede desactivar: hay reservas activas (${vuelo.reservasActivas}).',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
      );
      if (compacto) {
        return Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            editar,
            desactivar,
            if (vuelo.reservasActivas > 0) avisoReservas,
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          editar,
          const SizedBox(height: 8),
          desactivar,
          if (vuelo.reservasActivas > 0) avisoReservas,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Desde · por asiento',
            style: TextStyle(color: AeroColors.muted, fontSize: 12)),
        Text('${_dinero(vuelo.precioDesde)} USD',
            style: const TextStyle(
                color: AeroColors.navy,
                fontSize: 23,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        FilledButton.icon(
          style: FilledButton.styleFrom(
              backgroundColor: AeroColors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: const Size(0, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed:
              _vigente && vuelo.asientosDisponibles > 0 ? onReservar : null,
          icon: const Icon(Icons.event_seat_outlined, size: 18),
          label: Text(_vigente ? 'Seleccionar asientos' : 'No disponible',
              textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

class _TarifaClase extends StatelessWidget {
  final String nombre;
  final String precio;
  final int cupos;
  final bool ejecutiva;
  const _TarifaClase(
      {required this.nombre,
      required this.precio,
      required this.cupos,
      required this.ejecutiva});

  @override
  Widget build(BuildContext context) {
    final color = ejecutiva ? AeroColors.navy : AeroColors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: AeroColors.ice,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AeroColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
                ejecutiva
                    ? Icons.airline_seat_recline_extra
                    : Icons.airline_seat_recline_normal,
                size: 16,
                color: color),
            const SizedBox(width: 6),
            Text('$nombre · $precio',
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 4),
          Text(cupos == 0 ? 'Agotada' : '$cupos disponibles',
              style: TextStyle(
                  fontSize: 12,
                  color: cupos == 0
                      ? AeroColors.muted
                      : cupos <= 5
                          ? Colors.orange.shade900
                          : Colors.green.shade800)),
        ],
      ),
    );
  }
}

class _EstadoVuelo extends StatelessWidget {
  final Vuelo vuelo;
  const _EstadoVuelo({required this.vuelo});
  @override
  Widget build(BuildContext context) {
    final (texto, color) = switch (vuelo.situacion) {
      'FINALIZADO' => ('Finalizado', AeroColors.muted),
      'INACTIVO' => ('Inactivo', AeroColors.muted),
      'AGOTADO' => ('Agotado', Colors.orange.shade900),
      _ => ('Vigente', Colors.green.shade800),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(texto,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
