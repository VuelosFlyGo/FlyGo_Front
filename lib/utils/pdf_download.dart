import 'dart:typed_data';

import 'pdf_download_stub.dart' if (dart.library.html) 'pdf_download_web.dart'
    as plataforma;

void descargarPdf(Uint8List bytes, String nombreArchivo) {
  plataforma.descargarArchivo(bytes, nombreArchivo, 'application/pdf');
}

void descargarXml(Uint8List bytes, String nombreArchivo) {
  plataforma.descargarArchivo(bytes, nombreArchivo, 'application/xml');
}
