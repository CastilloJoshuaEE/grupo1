import 'package:flutter/material.dart';
import '../models/tarea.dart';

class TareaCard extends StatelessWidget {
  final Tarea tarea;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TareaCard({
    super.key,
    required this.tarea,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getPrioridadColor() {
    switch (tarea.prioridad.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: tarea.completada ? Colors.green.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: tarea.completada,
              onChanged: (_) => onToggle(),
              activeColor: Colors.green,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tarea.titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: tarea.completada
                          ? TextDecoration.lineThrough
                          : null,
                      color: tarea.completada ? Colors.grey : Colors.black,
                    ),
                  ),
                  if (tarea.descripcion.isNotEmpty)
                    Text(
                      tarea.descripcion,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildChip(
                        icon: Icons.calendar_today_rounded,
                        label: tarea.fechaEntrega.isNotEmpty
                            ? tarea.fechaEntrega
                            : 'Sin fecha',
                      ),
                      _buildChip(
                        icon: Icons.flag_rounded,
                        label: tarea.prioridad,
                        color: _getPrioridadColor(),
                      ),
                      if (tarea.categoriaNombre != null &&
                          tarea.categoriaNombre!.isNotEmpty)
                        _buildChip(
                          icon: Icons.folder_rounded,
                          label: tarea.categoriaNombre!,
                          color: Colors.grey.shade600,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  color: const Color(0xFF1565C0),
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

  Widget _buildChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color ?? Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}