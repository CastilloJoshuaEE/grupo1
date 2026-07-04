import 'package:flutter/material.dart';
import '../models/categoria.dart';

class CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Color(int.parse(categoria.color.replaceFirst('#', '0xFF'))),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                categoria.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
              color: const Color(0xFFFF6F00),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: onDelete,
              color: Colors.red.shade700,
            ),
          ],
        ),
      ),
    );
  }
}