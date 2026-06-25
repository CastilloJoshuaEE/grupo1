import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tarea_json.dart';

class VentanaTareasJSON extends StatefulWidget {
  const VentanaTareasJSON({super.key});

  @override
  State<VentanaTareasJSON> createState() => _VentanaTareasJSONState();
}

class _VentanaTareasJSONState extends State<VentanaTareasJSON> {
  List<TareaJson> _tareas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarTareasDesdeJSON();
  }

  Future<void> _cargarTareasDesdeJSON() async {
    try {
      // 1. Cargar el archivo JSON desde assets
      final String jsonString = await rootBundle.loadString(
        'assets/data/tareas.json',
      );

      // 2. Decodificar el JSON (array de objetos)
      final List<dynamic> jsonData = jsonDecode(jsonString);

      // 3. Convertir cada elemento a TareaJson
      setState(() {
        _tareas = jsonData.map((item) => TareaJson.fromJson(item)).toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los datos: $e';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas (JSON)'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarTareasDesdeJSON,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _tareas.isEmpty
                  ? const Center(
                      child: Text('No hay tareas disponibles'),
                    )
                  : _buildListaTareas(),
    );
  }

  Widget _buildListaTareas() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _tareas.length,
      itemBuilder: (context, index) {
        final tarea = _tareas[index];
        return _buildTareaCard(tarea);
      },
    );
  }

  Widget _buildTareaCard(TareaJson tarea) {
    // Color según prioridad
    Color colorPrioridad;
    switch (tarea.prioridad.toLowerCase()) {
      case 'alta':
        colorPrioridad = Colors.red;
        break;
      case 'media':
        colorPrioridad = Colors.orange;
        break;
      case 'baja':
        colorPrioridad = Colors.green;
        break;
      default:
        colorPrioridad = Colors.grey;
    }

    // Color según estado de completada
    Color colorFondo = tarea.completada ? Colors.green.shade50 : Colors.white;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: tarea.completada ? Colors.green.shade300 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      color: colorFondo,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título en negrita alineado a la izquierda
            Row(
              children: [
                Expanded(
                  child: Text(
                    tarea.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17324D),
                    ),
                  ),
                ),
                // Indicador de completada
                if (tarea.completada)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Completada',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Descripción
            Text(
              tarea.descripcion,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 12),
            // Fila de información: fecha, prioridad, categoría
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _buildInfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: 'Entrega: ${tarea.fechaEntrega}',
                ),
                _buildInfoChip(
                  icon: Icons.flag_rounded,
                  label: tarea.prioridad,
                  colorTexto: colorPrioridad,
                ),
                _buildInfoChip(
                  icon: Icons.folder_rounded,
                  label: tarea.categoria,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color colorTexto = Colors.grey,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorTexto),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorTexto,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}