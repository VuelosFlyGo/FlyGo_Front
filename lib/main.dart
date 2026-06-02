import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const AeroTechApp());
}

class AeroTechApp extends StatelessWidget {
  const AeroTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AeroTech Reservas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}
