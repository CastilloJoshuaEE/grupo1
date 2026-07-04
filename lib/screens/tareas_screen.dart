import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/tarea.dart';
import '../models/categoria.dart';
import '../widgets/tarea_card.dart';

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  List<Tarea> _tareas = [];
  List<Tarea> _tareasFiltradas = [];
  String _filtro = 'todas';
  bool _cargando = true;
  int _estudianteId = 0;

  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    _estudianteId = await _storage.getEstudianteIdSesion();
    await _cargarTareas();
    if (mounted) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cargarTareas() async {
    final tareas = await _storage.getTareas(estudianteId: _estudianteId);
    
    // Obtener nombres de categorías
    final categorias = await _storage.getCategorias(estudianteId: _estudianteId);
    final mapCategorias = {for (var c in categorias) c.id: c.nombre};
    
    for (var tarea in tareas) {
      tarea.categoriaNombre = mapCategorias[tarea.categoriaId];
    }
    
    if (mounted) {
      setState(() {
        _tareas = tareas;
        _aplicarFiltro();
      });
    }
  }

  void _aplicarFiltro() {
    setState(() {
      switch (_filtro) {
        case 'pendientes':
          _tareasFiltradas = _tareas.where((t) => !t.completada).toList();
          break;
        case 'completadas':
          _tareasFiltradas = _tareas.where((t) => t.completada).toList();
          break;
        default:
          _tareasFiltradas = List.from(_tareas);
      }
    });
  }

  Future<void> _mostrarFormulario({Tarea? tareaExistente}) async {
    final formKey = GlobalKey<FormState>();
    final tituloController = TextEditingController(text: tareaExistente?.titulo);
    final descController = TextEditingController(text: tareaExistente?.descripcion);
    final prioridadController = TextEditingController(
      text: tareaExistente?.prioridad ?? 'Media',
    );
    DateTime? fechaSeleccionada;

    // Obtener categorías
    final categorias = await _storage.getCategorias(estudianteId: _estudianteId);
    String? categoriaSeleccionada;
    if (tareaExistente != null) {
      final cat = categorias.firstWhere(
        (c) => c.id == tareaExistente.categoriaId,
        orElse: () => Categoria(id: -1, nombre: ''),
      );
      categoriaSeleccionada = cat.nombre.isNotEmpty ? cat.nombre : null;
    }

    if (tareaExistente != null && tareaExistente.fechaEntrega.isNotEmpty) {
      try {
        fechaSeleccionada = DateFormat('yyyy-MM-dd').parse(tareaExistente.fechaEntrega);
      } catch (_) {}
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(tareaExistente == null ? 'Nueva Tarea' : 'Editar Tarea'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: prioridadController.text,
                      decoration: const InputDecoration(
                        labelText: 'Prioridad',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                        DropdownMenuItem(value: 'Media', child: Text('Media')),
                        DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          prioridadController.text = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: categoriaSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      items: categorias.map((c) {
                        return DropdownMenuItem(
                          value: c.nombre,
                          child: Text(c.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          categoriaSeleccionada = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: fechaSeleccionada ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setStateDialog(() {
                            fechaSeleccionada = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de entrega',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          fechaSeleccionada == null
                              ? 'Seleccione una fecha'
                              : DateFormat('dd/MM/yyyy').format(fechaSeleccionada!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'titulo': tituloController.text.trim(),
                      'descripcion': descController.text.trim(),
                      'prioridad': prioridadController.text,
                      'categoria': categoriaSeleccionada,
                      'fecha': fechaSeleccionada != null
                          ? DateFormat('yyyy-MM-dd').format(fechaSeleccionada!)
                          : '',
                    });
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );

    if (result == null || !mounted) return;

    // Obtener ID de categoría
    final catId = await _storage.getIdCategoriaPorNombre(
      result['categoria'] ?? '',
      _estudianteId,
    );

    if (tareaExistente == null) {
      final tarea = Tarea(
        titulo: result['titulo'],
        descripcion: result['descripcion'],
        fechaEntrega: result['fecha'],
        prioridad: result['prioridad'],
        categoriaId: catId,
        estudianteId: _estudianteId,
      );
      await _storage.insertarTarea(tarea);
    } else {
      final tareaActualizada = Tarea(
        id: tareaExistente.id,
        titulo: result['titulo'],
        descripcion: result['descripcion'],
        fechaEntrega: result['fecha'],
        prioridad: result['prioridad'],
        completada: tareaExistente.completada,
        categoriaId: catId,
        categoriaNombre: tareaExistente.categoriaNombre,
        estudianteId: _estudianteId,
      );
      await _storage.actualizarTarea(tareaActualizada);
    }

    await _cargarTareas();
  }

  Future<void> _toggleCompletada(Tarea tarea) async {
    await _storage.marcarTareaCompletada(tarea.id!, !tarea.completada);
    await _cargarTareas();
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${tarea.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _storage.eliminarTarea(tarea.id!);
      await _cargarTareas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFiltroChip('Todas', 'todas'),
                const SizedBox(width: 8),
                _buildFiltroChip('Pendientes', 'pendientes'),
                const SizedBox(width: 8),
                _buildFiltroChip('Completadas', 'completadas'),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _tareasFiltradas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_alt_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay tareas',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toca el botón + para agregar una tarea',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _tareasFiltradas.length,
                        itemBuilder: (context, index) {
                          final tarea = _tareasFiltradas[index];
                          return TareaCard(
                            tarea: tarea,
                            onToggle: () => _toggleCompletada(tarea),
                            onEdit: () => _mostrarFormulario(tareaExistente: tarea),
                            onDelete: () => _eliminarTarea(tarea),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFiltroChip(String label, String valor) {
    final seleccionado = _filtro == valor;
    return FilterChip(
      label: Text(label),
      selected: seleccionado,
      onSelected: (_) {
        setState(() {
          _filtro = valor;
          _aplicarFiltro();
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: const Color(0xFF1565C0).withOpacity(0.2),
      checkmarkColor: const Color(0xFF1565C0),
      labelStyle: TextStyle(
        color: seleccionado ? const Color(0xFF1565C0) : Colors.grey.shade700,
        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}