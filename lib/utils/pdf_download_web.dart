// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

void descargarArchivo(
    Uint8List bytes, String nombreArchivo, String tipoContenido) {
  final blob = html.Blob([bytes], tipoContenido);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final enlace = html.AnchorElement(href: url)
    ..download = nombreArchivo
    ..target = '_blank'
    ..style.display = 'none';
  html.document.body?.append(enlace);
  enlace.click();
  enlace.remove();

  // Algunos navegadores cancelan la descarga si el Blob se libera
  // en el mismo ciclo en que se dispara el clic.
  Timer(
    const Duration(seconds: 3),
    () => html.Url.revokeObjectUrl(url),
  );
}
