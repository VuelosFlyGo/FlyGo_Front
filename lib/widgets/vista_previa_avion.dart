import 'package:flutter/material.dart';

import '../models/avion.dart';
import '../theme/aerotech_theme.dart';

/// Esquema de la cabina 2–2 que se generará al registrar el vuelo.
class VistaPreviaAvion extends StatefulWidget {
  final Avion avion;

  const VistaPreviaAvion({super.key, required this.avion});

  @override
  State<VistaPreviaAvion> createState() => _VistaPreviaAvionState();
}

class _VistaPreviaAvionState extends State<VistaPreviaAvion> {
  final _scroll = ScrollController();
  static const _anchoFila = 22.0;
  static const _separacion = 10.0;
  static const _turista = Color(0xFFEAF1FF);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avion = widget.avion;
    final filas = (avion.capacidad + 3) ~/ 4;
    final filasEjecutiva = (avion.ejecutiva + 3) ~/ 4;
    final ancho = 96 + filas * _anchoFila + _separacion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.flight_outlined, color: AeroColors.navy, size: 19),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Vista previa de la cabina',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AeroColors.ink),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Distribución 2–2 · filas numeradas de frente a cola',
          style: TextStyle(color: AeroColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final desplazable = ancho > constraints.maxWidth;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Scrollbar(
                  controller: _scroll,
                  thumbVisibility: desplazable,
                  child: SingleChildScrollView(
                    controller: _scroll,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: ancho,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(58),
                            right: Radius.circular(22),
                          ),
                          border: Border.all(color: AeroColors.line),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 40,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RotatedBox(
                                    quarterTurns: 3,
                                    child: Icon(Icons.flight,
                                        color: AeroColors.navy, size: 22),
                                  ),
                                  Text('Frente',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AeroColors.navy)),
                                ],
                              ),
                            ),
                            const _LetrasCabina(),
                            for (var fila = 0; fila < filas; fila++) ...[
                              if (fila == filasEjecutiva)
                                const SizedBox(
                                  width: _separacion,
                                  height: 100,
                                  child: VerticalDivider(
                                    color: AeroColors.line,
                                    width: _separacion,
                                  ),
                                ),
                              _fila(fila),
                            ],
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (desplazable)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text('Desliza para ver todas las filas.',
                        style:
                            TextStyle(color: AeroColors.muted, fontSize: 12)),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        const Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _LeyendaClase(color: AeroColors.navy, texto: 'Ejecutiva'),
            _LeyendaClase(color: _turista, texto: 'Turista'),
          ],
        ),
      ],
    );
  }

  Widget _fila(int fila) {
    return SizedBox(
      width: _anchoFila,
      child: Column(
        children: [
          _asiento(fila, 0),
          _asiento(fila, 1),
          SizedBox(
            height: 26,
            child: Center(
              child: Text('${fila + 1}',
                  style:
                      const TextStyle(fontSize: 10, color: AeroColors.muted)),
            ),
          ),
          _asiento(fila, 2),
          _asiento(fila, 3),
        ],
      ),
    );
  }

  Widget _asiento(int fila, int columna) {
    final indice = fila * 4 + columna;
    if (indice >= widget.avion.capacidad) {
      return const SizedBox(height: 20);
    }
    final ejecutivo = indice < widget.avion.ejecutiva;
    final numero = '${fila + 1}${'ABCD'[columna]}';
    return Tooltip(
      message: '$numero · ${ejecutivo ? 'Ejecutiva' : 'Turista'}',
      child: Container(
        key: ValueKey('preview-seat-$numero'),
        width: 16,
        height: 16,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: ejecutivo ? AeroColors.navy : _turista,
          borderRadius: BorderRadius.circular(4),
          border:
              Border.all(color: ejecutivo ? AeroColors.navy : AeroColors.cyan),
        ),
      ),
    );
  }
}

class _LetrasCabina extends StatelessWidget {
  const _LetrasCabina();

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(color: AeroColors.muted, fontSize: 10);
    return const SizedBox(
      width: 24,
      child: Column(
        children: [
          SizedBox(height: 20, child: Center(child: Text('A', style: estilo))),
          SizedBox(height: 20, child: Center(child: Text('B', style: estilo))),
          SizedBox(height: 26),
          SizedBox(height: 20, child: Center(child: Text('C', style: estilo))),
          SizedBox(height: 20, child: Center(child: Text('D', style: estilo))),
        ],
      ),
    );
  }
}

class _LeyendaClase extends StatelessWidget {
  final Color color;
  final String texto;
  const _LeyendaClase({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
                color: color == AeroColors.navy
                    ? AeroColors.navy
                    : AeroColors.cyan),
          ),
        ),
        const SizedBox(width: 6),
        Text(texto,
            style: const TextStyle(color: AeroColors.ink, fontSize: 12)),
      ],
    );
  }
}
