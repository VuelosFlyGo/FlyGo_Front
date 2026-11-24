import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/asiento.dart';
import '../theme/aerotech_theme.dart';
import 'asiento_boton.dart';

class CabinaAsientos extends StatelessWidget {
  final List<Asiento> asientos;
  final List<String> seleccionados;
  final int? reservaId;
  final ValueChanged<Asiento> onAsientoTap;

  const CabinaAsientos({
    super.key,
    required this.asientos,
    required this.seleccionados,
    required this.onAsientoTap,
    this.reservaId,
  });

  SplayTreeMap<int, Map<String, Asiento>> get _filas {
    final filas = SplayTreeMap<int, Map<String, Asiento>>();
    final patron = RegExp(r'^(\d+)([A-Za-z])$');
    for (final asiento in asientos) {
      final coincidencia = patron.firstMatch(asiento.numeroAsiento);
      if (coincidencia == null) continue;
      final fila = int.parse(coincidencia.group(1)!);
      final letra = coincidencia.group(2)!.toUpperCase();
      filas.putIfAbsent(fila, () => <String, Asiento>{})[letra] = asiento;
    }
    return filas;
  }

  @override
  Widget build(BuildContext context) {
    final filas = _filas;
    return LayoutBuilder(
      builder: (context, constraints) {
        final anchoContenido = constraints.maxWidth.clamp(0.0, 620.0);
        final anchoUtil = (anchoContenido - 32).clamp(0.0, 620.0);
        final compacta = anchoUtil < 430;
        final anchoCabina = compacta ? anchoUtil.clamp(300.0, 350.0) : 430.0;
        final anchoAsiento = compacta ? 48.0 : 58.0;
        final anchoPasillo = compacta ? 44.0 : 58.0;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 620,
                minWidth: anchoUtil,
              ),
              child: Column(
                children: [
                  _CabinaMeta(total: asientos.length),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: anchoCabina,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFE),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(110),
                            bottom: Radius.circular(72),
                          ),
                          border: Border.all(color: AeroColors.line),
                          boxShadow: [
                            BoxShadow(
                              color: AeroColors.navy.withValues(alpha: .07),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const _Cockpit(),
                            _Columnas(
                              anchoAsiento: anchoAsiento,
                              anchoPasillo: anchoPasillo,
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                compacta ? 8 : 20,
                                8,
                                compacta ? 8 : 20,
                                18,
                              ),
                              child: Column(
                                children: filas.entries.map((entrada) {
                                  return _FilaCabina(
                                    numero: entrada.key,
                                    asientos: entrada.value,
                                    seleccionados: seleccionados,
                                    reservaId: reservaId,
                                    anchoAsiento: anchoAsiento,
                                    anchoPasillo: anchoPasillo,
                                    onTap: onAsientoTap,
                                  );
                                }).toList(),
                              ),
                            ),
                            const _SalidaPosterior(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CabinaMeta extends StatelessWidget {
  final int total;
  const _CabinaMeta({required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 18,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.airline_seat_recline_normal,
                    size: 18, color: AeroColors.navy),
                SizedBox(width: 7),
                Text('Cabina 2–2',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            Text('$total asientos',
                style: const TextStyle(color: AeroColors.muted)),
          ],
        ),
        const SizedBox(height: 9),
        const Wrap(
          spacing: 14,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _Leyenda(
                color: Color(0xFFEAF1FF),
                borde: AeroColors.cyan,
                texto: 'Disponible'),
            _Leyenda(
                color: AeroColors.blue,
                borde: AeroColors.blue,
                texto: 'Seleccionado'),
            _Leyenda(
                color: Color(0xFFF1F3F7),
                borde: Color(0xFFCAD1DE),
                texto: 'Ocupado'),
          ],
        ),
      ],
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final Color borde;
  final String texto;
  const _Leyenda(
      {required this.color, required this.borde, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borde),
          ),
        ),
        const SizedBox(width: 6),
        Text(texto,
            style: const TextStyle(fontSize: 12, color: AeroColors.muted)),
      ],
    );
  }
}

class _Cockpit extends StatelessWidget {
  const _Cockpit();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AeroColors.navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(108)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight, color: Colors.white, size: 27),
          SizedBox(height: 5),
          Text('FRENTE · CABINA',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .8)),
        ],
      ),
    );
  }
}

class _Columnas extends StatelessWidget {
  final double anchoAsiento;
  final double anchoPasillo;
  const _Columnas({required this.anchoAsiento, required this.anchoPasillo});

  @override
  Widget build(BuildContext context) {
    Widget letra(String valor) => SizedBox(
          width: anchoAsiento,
          child: Center(
              child: Text(valor,
                  style: const TextStyle(
                      color: AeroColors.muted, fontWeight: FontWeight.w800))),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          letra('A'),
          letra('B'),
          SizedBox(
              width: anchoPasillo,
              child: const Center(
                  child: Text('PASILLO',
                      style: TextStyle(
                          fontSize: 8,
                          color: AeroColors.muted,
                          fontWeight: FontWeight.w800)))),
          letra('C'),
          letra('D'),
        ],
      ),
    );
  }
}

class _FilaCabina extends StatelessWidget {
  final int numero;
  final Map<String, Asiento> asientos;
  final List<String> seleccionados;
  final int? reservaId;
  final double anchoAsiento;
  final double anchoPasillo;
  final ValueChanged<Asiento> onTap;

  const _FilaCabina({
    required this.numero,
    required this.asientos,
    required this.seleccionados,
    required this.onTap,
    required this.anchoAsiento,
    required this.anchoPasillo,
    this.reservaId,
  });

  Widget _asiento(String letra) {
    final asiento = asientos[letra];
    if (asiento == null) return SizedBox(width: anchoAsiento, height: 64);
    return SizedBox(
      width: anchoAsiento,
      child: AsientoBoton(
        asiento: asiento,
        seleccionado: seleccionados.contains(asiento.numeroAsiento),
        habilitado: reservaId != null && asiento.reservaId == reservaId,
        onTap: () => onTap(asiento),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _Ventana(),
          _asiento('A'),
          _asiento('B'),
          SizedBox(
            width: anchoPasillo,
            child: Center(
              child: Text('$numero',
                  style: const TextStyle(
                      color: AeroColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          _asiento('C'),
          _asiento('D'),
          const _Ventana(),
        ],
      ),
    );
  }
}

class _Ventana extends StatelessWidget {
  const _Ventana();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFB8C7DF),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _SalidaPosterior extends StatelessWidget {
  const _SalidaPosterior();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(38, 8, 38, 28),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AeroColors.navy.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.exit_to_app, size: 17, color: AeroColors.navy),
          SizedBox(width: 8),
          Text('SALIDA POSTERIOR',
              style: TextStyle(
                  fontSize: 10,
                  color: AeroColors.navy,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .6)),
        ],
      ),
    );
  }
}
