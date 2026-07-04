import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tareas_screen.dart';
import 'screens/apuntes_screen.dart';
import 'screens/recordatorios_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/admin_estudiantes_screen.dart';
import 'screens/categorias_screen.dart';

void main() {
  runApp(const EduTaskApp());
}

class EduTaskApp extends StatelessWidget {
  const EduTaskApp({super.key});

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
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/tareas': (context) => const TareasScreen(),
        '/apuntes': (context) => const ApuntesScreen(),
        '/recordatorios': (context) => const RecordatoriosScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/admin_estudiantes': (context) => const AdminEstudiantesScreen(),
        '/categorias': (context) => const CategoriasScreen(),
      },
    );
  }
}