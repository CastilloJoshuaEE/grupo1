import 'package:flutter/material.dart';

class AcercaDeDialog extends StatelessWidget {
  const AcercaDeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ACERCA DE'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'UNIVERSIDAD DE GUAYAQUIL\n'
              'FACULTAD DE CIENCIAS MATEMÁTICAS Y FÍSICAS\n'
              'CARRERA INGENIERÍA EN SOFTWARE\n\n'
              'DESARROLLO DE APLICACIONES MÓVILES\n'
              'DOCENTE: ING. CHARCO AGUIRRE JORGE LUIS\n\n'
              'CURSO: SOF-S-VE-8-4\n\n'
              '=== INTEGRANTES DEL GRUPO #1 ===\n\n'
              '• CASTILLO MEREJILDO JOSHUA JAVIER\n'
              '• ESPINOZA GOMEZ JENNIFFER MARISOL\n'
              '• GABINO VILLAO JOEL FABIAN\n'
              '• PARRA AGUAYO KEVIN JOEL\n'
              '• VERA CHUQUIMARCA LESLIE ARIANNA\n\n'
              'PROYECTO: EduTask\n'
              'Aplicación móvil para la gestión académica\n\n'
              'AÑO: 2026 – 2027 Ciclo I',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}