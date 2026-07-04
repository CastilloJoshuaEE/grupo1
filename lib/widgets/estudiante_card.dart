import 'package:flutter/material.dart';
import '../models/estudiante.dart';

class EstudianteCard extends StatelessWidget {
  final Estudiante estudiante;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EstudianteCard({
    super.key,
    required this.estudiante,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final esAdmin = estudiante.rol == 'administrador';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.person_rounded, size: 28, color: Color(0xFF9C27B0)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estudiante.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    estudiante.correo,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '📄 Cédula: ${estudiante.cedula}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: esAdmin ? const Color(0xFF9C27B0) : const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      esAdmin ? '👑 Administrador' : '📚 Estudiante',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  color: const Color(0xFF9C27B0),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  color: Colors.red.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}