import 'package:flutter/material.dart';
import 'package:fifa/views/ventanaLogin.dart';
import 'package:fifa/views/ventanaPrincipal.dart';
import 'package:fifa/views/ventanaRegistro.dart';
import 'package:fifa/views/ventanaTareasJSON.dart';  

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorPrimario = Color(0xFF1565C0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduTask',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorPrimario,
          primary: colorPrimario,
          secondary: const Color(0xFF2E7D32),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD7DEE8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD7DEE8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: colorPrimario, width: 2),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePageVentanaLogin(title: 'EduTask'),
        'principal': (context) => const MyHomePageVentanaPrincipal(),
        'registro': (context) => const MyHomePageVentanaRegistro(),
        'json_tareas': (context) => const VentanaTareasJSON(), 
      },
    );
  }
}