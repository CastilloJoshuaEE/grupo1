import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/estudiante.dart';
import '../widgets/estudiante_card.dart';

class AdminEstudiantesScreen extends StatefulWidget {
  const AdminEstudiantesScreen({super.key});

  @override
  State<AdminEstudiantesScreen> createState() => _AdminEstudiantesScreenState();
}

class _AdminEstudiantesScreenState extends State<AdminEstudiantesScreen> {
  List<Estudiante> _estudiantes = [];
  List<Estudiante> _estudiantesFiltrados = [];
  bool _cargando = true;
  final TextEditingController _busquedaController = TextEditingController();

  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    await _cargarEstudiantes();
    setState(() => _cargando = false);
  }

  Future<void> _cargarEstudiantes() async {
    final estudiantes = await _storage.getEstudiantesActivos();
    setState(() {
      _estudiantes = estudiantes;
      _aplicarFiltro();
    });
  }

  void _aplicarFiltro() {
    final busqueda = _busquedaController.text.trim();
    if (busqueda.isEmpty) {
      setState(() {
        _estudiantesFiltrados = List.from(_estudiantes);
      });
    } else {
      setState(() {
        _estudiantesFiltrados = _estudiantes.where(
          (e) => e.cedula.contains(busqueda)
        ).toList();
      });
    }
  }

  Future<void> _mostrarFormulario({Estudiante? estudianteExistente}) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(
      text: estudianteExistente?.nombre,
    );
    final correoController = TextEditingController(
      text: estudianteExistente?.correo,
    );
    final cedulaController = TextEditingController(
      text: estudianteExistente?.cedula,
    );
    final passwordController = TextEditingController();
    String? rolSeleccionado = estudianteExistente?.rol ?? 'estudiante';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(estudianteExistente == null ? 'Nuevo Estudiante' : 'Editar Estudiante'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: correoController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: estudianteExistente == null,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el correo';
                        }
                        final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
                        if (!regex.hasMatch(value.trim())) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: cedulaController,
                      enabled: estudianteExistente == null,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Cédula',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length != 10) {
                          return 'La cédula debe tener 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: estudianteExistente == null ? 'Contraseña' : 'Nueva contraseña (opcional)',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (estudianteExistente == null) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese una contraseña';
                          }
                          if (value.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: rolSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'estudiante', child: Text('Estudiante')),
                        DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          rolSeleccionado = value!;
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
                      'correo': correoController.text.trim(),
                      'cedula': cedulaController.text.trim(),
                      'password': passwordController.text.trim(),
                      'rol': rolSeleccionado,
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

    if (result == null) return;

    if (estudianteExistente == null) {
      // Verificar si el correo ya existe
      final existe = await _storage.correoExiste(result['correo']);
      if (existe) {
        _mostrarMensaje('El correo ya está registrado', esError: true);
        return;
      }

      final estudiante = Estudiante(
        nombre: result['nombre'],
        correo: result['correo'],
        password: result['password'],
        cedula: result['cedula'],
        rol: result['rol'],
      );
      await _storage.insertarEstudiante(estudiante);
      _mostrarMensaje('Estudiante registrado correctamente');
    } else {
      // Actualizar
      final password = result['password'].isNotEmpty ? result['password'] : estudianteExistente.password;
      final estudianteActualizado = estudianteExistente.copyWith(
        nombre: result['nombre'],
        cedula: result['cedula'],
        password: password,
        rol: result['rol'],
      );
      await _storage.actualizarEstudiante(estudianteActualizado);
      _mostrarMensaje('Estudiante actualizado correctamente');
    }

    await _cargarEstudiantes();
  }

  Future<void> _eliminarEstudiante(Estudiante estudiante) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar estudiante'),
        content: Text('¿Eliminar a ${estudiante.nombre}?'),
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

    if (confirm == true) {
      await _storage.desactivarEstudiante(estudiante.id!);
      _mostrarMensaje('Estudiante eliminado');
      await _cargarEstudiantes();
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
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Estudiantes'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _busquedaController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por cédula',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (_) => _aplicarFiltro(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _busquedaController.clear();
                    _aplicarFiltro();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _estudiantesFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay estudiantes',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _estudiantesFiltrados.length,
                        itemBuilder: (context, index) {
                          final estudiante = _estudiantesFiltrados[index];
                          return EstudianteCard(
                            estudiante: estudiante,
                            onEdit: () => _mostrarFormulario(
                              estudianteExistente: estudiante,
                            ),
                            onDelete: () => _eliminarEstudiante(estudiante),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFF9C27B0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}