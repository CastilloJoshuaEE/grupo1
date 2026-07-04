import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/categoria.dart';
import '../widgets/categoria_card.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  List<Categoria> _categorias = [];
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
    await _cargarCategorias();
    if (mounted) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cargarCategorias() async {
    final categorias = await _storage.getCategorias(
      estudianteId: _estudianteId,
    );
    if (mounted) {
      setState(() {
        _categorias = categorias;
      });
    }
  }

  Future<void> _mostrarFormulario({Categoria? categoriaExistente}) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: categoriaExistente?.nombre);
    final colorController = TextEditingController(
      text: categoriaExistente?.color ?? '#2196F3',
    );

    final colores = [
      '#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5',
      '#2196F3', '#03A9F4', '#00BCD4', '#009688', '#4CAF50',
      '#8BC34A', '#CDDC39', '#FFEB3B', '#FFC107', '#FF9800',
      '#FF5722', '#795548', '#9E9E9E', '#607D8B',
    ];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(categoriaExistente == null ? 'Nueva Categoría' : 'Editar Categoría'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la categoría',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: colorController.text,
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        border: OutlineInputBorder(),
                      ),
                      items: colores.map((color) {
                        return DropdownMenuItem(
                          value: color,
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(color),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          colorController.text = value!;
                        });
                      },
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
                      'nombre': nombreController.text.trim(),
                      'color': colorController.text,
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

    if (categoriaExistente == null) {
      final categoria = Categoria(
        nombre: result['nombre'],
        color: result['color'],
        estudianteId: _estudianteId,
      );
      await _storage.insertarCategoria(categoria);
      _mostrarMensaje('Categoría creada correctamente');
    } else {
      final categoriaActualizada = Categoria(
        id: categoriaExistente.id,
        nombre: result['nombre'],
        color: result['color'],
        estudianteId: categoriaExistente.estudianteId,
      );
      await _storage.actualizarCategoria(categoriaActualizada);
      _mostrarMensaje('Categoría actualizada correctamente');
    }

    await _cargarCategorias();
  }

  Future<void> _eliminarCategoria(Categoria categoria) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Eliminar "${categoria.nombre}"?'),
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
      await _storage.eliminarCategoria(categoria.id!);
      _mostrarMensaje('Categoría eliminada');
      await _cargarCategorias();
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        backgroundColor: const Color(0xFFFF6F00),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _categorias.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay categorías',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca el botón + para agregar una categoría',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = _categorias[index];
                    return CategoriaCard(
                      categoria: categoria,
                      onEdit: () => _mostrarFormulario(
                        categoriaExistente: categoria,
                      ),
                      onDelete: () => _eliminarCategoria(categoria),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFFFF6F00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}