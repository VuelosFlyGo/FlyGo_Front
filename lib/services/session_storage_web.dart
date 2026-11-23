// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;

class SessionStorage {
  static Future<String?> leer(String clave) async {
    final actual = html.window.localStorage[clave];
    if (actual != null) return actual;

    final legado = html.window.localStorage['flutter.$clave'];
    if (legado == null) return null;
    try {
      final decodificado = jsonDecode(legado);
      return decodificado is String ? decodificado : null;
    } catch (_) {
      return legado;
    }
  }

  static Future<void> escribir(String clave, String valor) async {
    html.window.localStorage[clave] = valor;
    html.window.localStorage.remove('flutter.$clave');
  }

  static Future<void> eliminar(String clave) async {
    html.window.localStorage.remove(clave);
    html.window.localStorage.remove('flutter.$clave');
  }
}
