import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static Stream<void> cambios(String clave) => const Stream<void>.empty();

  static Stream<void> get reactivaciones => const Stream<void>.empty();

  static Future<String?> leer(String clave) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(clave);
  }

  static Future<void> escribir(String clave, String valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(clave, valor);
  }

  static Future<void> eliminar(String clave) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(clave);
  }
}
