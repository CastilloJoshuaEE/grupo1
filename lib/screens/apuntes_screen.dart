import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/apunte.dart';
import '../models/categoria.dart';
import '../widgets/apunte_card.dart';

class ApuntesScreen extends StatefulWidget {
  const ApuntesScreen({super.key});

  @override
  State<ApuntesScreen> createState() => _ApuntesScreenState();
}

class _ApuntesScreenState extends State<ApuntesScreen> {
  List<Apunte> _apuntes = [];
  List<Apunte> _apuntesFiltrados = [];
  String _filtroCategoria = 'todas';
  bool _cargando = true;
  int _estudianteId = 0;
  List<String> _nombresCategorias = [];

  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    _estudianteId = await _storage.getEstudianteIdSesion();
    await _cargarApuntes();
    if (mounted) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cargarApuntes() async {
    final apuntes = await _storage.getApuntes(estudianteId: _estudianteId);
    
    // Obtener nombres de categorías
    final categorias = await _storage.getCategorias(estudianteId: _estudianteId);
    final mapCategorias = {for (var c in categorias) c.id: c.nombre};
    _nombresCategorias = categorias.map((c) => c.nombre).toList();
    
    for (var apunte in apuntes) {
      apunte.categoriaNombre = mapCategorias[apunte.categoriaId];
    }
    
    if (mounted) {
      setState(() {
        _apuntes = apuntes;
        _aplicarFiltro();
      });
    }
  }

  void _aplicarFiltro() {
    setState(() {
      if (_filtroCategoria == 'todas') {
        _apuntesFiltrados = List.from(_apuntes);
      } else {
        _apuntesFiltrados = _apuntes.where(
          (a) => a.categoriaNombre == _filtroCategoria
        ).toList();
      }
    });
  }

  Future<void> _mostrarFormulario({Apunte? apunteExistente}) async {
    final formKey = GlobalKey<FormState>();
    final tituloController = TextEditingController(text: apunteExistente?.titulo);
    final contenidoController = TextEditingController(text: apunteExistente?.contenido);
    
    // Obtener categorías
    final categorias = await _storage.getCategorias(estudianteId: _estudianteId);
    String? categoriaSeleccionada;
    if (apunteExistente != null) {
      final cat = categorias.firstWhere(
        (c) => c.id == apunteExistente.categoriaId,
        orElse: () => Categoria(id: -1, nombre: ''),
      );
      categoriaSeleccionada = cat.nombre.isNotEmpty ? cat.nombre : null;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(apunteExistente == null ? 'Nuevo Apunte' : 'Editar Apunte'),
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
                      controller: contenidoController,
                      decoration: const InputDecoration(
                        labelText: 'Contenido',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
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
                      'contenido': contenidoController.text.trim(),
                      'categoria': categoriaSeleccionada,
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

    final fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

    if (apunteExistente == null) {
      final apunte = Apunte(
        titulo: result['titulo'],
        contenido: result['contenido'],
        fecha: fecha,
        categoriaId: catId,
        estudianteId: _estudianteId,
      );
      await _storage.insertarApunte(apunte);
    } else {
      final apunteActualizado = Apunte(
        id: apunteExistente.id,
        titulo: result['titulo'],
        contenido: result['contenido'],
        fecha: apunteExistente.fecha,
        categoriaId: catId,
        categoriaNombre: apunteExistente.categoriaNombre,
        tareaId: apunteExistente.tareaId,
        estudianteId: _estudianteId,
      );
      await _storage.actualizarApunte(apunteActualizado);
    }

    await _cargarApuntes();
  }

  Future<void> _eliminarApunte(Apunte apunte) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar apunte'),
        content: Text('¿Eliminar "${apunte.titulo}"?'),
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
      await _storage.eliminarApunte(apunte.id!);
      await _cargarApuntes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Apuntes'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtro por categoría
          if (_nombresCategorias.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFiltroChip('Todas', 'todas'),
                    const SizedBox(width: 8),
                    ..._nombresCategorias.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFiltroChip(cat, cat),
                      );
                    }),
                  ],
                ),
              ),
            ),
          // Lista
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _apuntesFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_alt_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay apuntes',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toca el botón + para agregar un apunte',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _apuntesFiltrados.length,
                        itemBuilder: (context, index) {
                          final apunte = _apuntesFiltrados[index];
                          return ApunteCard(
                            apunte: apunte,
                            onEdit: () => _mostrarFormulario(apunteExistente: apunte),
                            onDelete: () => _eliminarApunte(apunte),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFiltroChip(String label, String valor) {
    final seleccionado = _filtroCategoria == valor;
    return FilterChip(
      label: Text(label),
      selected: seleccionado,
      onSelected: (_) {
        setState(() {
          _filtroCategoria = valor;
          _aplicarFiltro();
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2E7D32),
      labelStyle: TextStyle(
        color: seleccionado ? const Color(0xFF2E7D32) : Colors.grey.shade700,
        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}