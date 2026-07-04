import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/estudiante.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _cargando = true;
  bool _guardando = false;
  Estudiante? _estudiante;
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _passwordActualController = TextEditingController();
  final _passwordNuevaController = TextEditingController();

  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final id = await _storage.getEstudianteIdSesion();
    if (id != -1) {
      _estudiante = await _storage.getEstudianteById(id);
      if (_estudiante != null) {
        _nombreController.text = _estudiante!.nombre;
        _cedulaController.text = _estudiante!.cedula;
      }
    }
    setState(() => _cargando = false);
  }

  Future<void> _guardarCambios() async {
    final nombre = _nombreController.text.trim();
    final cedula = _cedulaController.text.trim();
    final passActual = _passwordActualController.text.trim();
    final passNueva = _passwordNuevaController.text.trim();

    if (nombre.isEmpty) {
      _mostrarMensaje('Ingrese su nombre', esError: true);
      return;
    }

    setState(() => _guardando = true);

    String passwordFinal = _estudiante!.password;

    // Cambiar contraseña
    if (passNueva.isNotEmpty) {
      if (passActual.isEmpty) {
        setState(() => _guardando = false);
        _mostrarMensaje('Ingrese su contraseña actual', esError: true);
        return;
      }
      if (passActual != _estudiante!.password) {
        setState(() => _guardando = false);
        _mostrarMensaje('Contraseña actual incorrecta', esError: true);
        return;
      }
      if (passNueva.length < 6) {
        setState(() => _guardando = false);
        _mostrarMensaje('La nueva contraseña debe tener al menos 6 caracteres', esError: true);
        return;
      }
      passwordFinal = passNueva;
    }

    final estudianteActualizado = _estudiante!.copyWith(
      nombre: nombre,
      cedula: cedula,
      password: passwordFinal,
    );

    final exito = await _storage.actualizarEstudiante(estudianteActualizado);
    setState(() => _guardando = false);

    if (exito) {
      // Actualizar sesión
      await _storage.guardarSesion(
        _estudiante!.id!,
        nombre,
        _estudiante!.rol,
        _estudiante!.correo,
      );
      setState(() {
        _estudiante = estudianteActualizado;
        _passwordActualController.clear();
        _passwordNuevaController.clear();
      });
      _mostrarMensaje('Perfil actualizado correctamente');
    } else {
      _mostrarMensaje('Error al actualizar el perfil', esError: true);
    }
  }

  Future<void> _eliminarCuenta() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Está seguro de que desea eliminar su cuenta? Esta acción no se puede deshacer.',
        ),
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
      await _storage.desactivarEstudiante(_estudiante!.id!);
      await _storage.cerrarSesion();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
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
    _nombreController.dispose();
    _cedulaController.dispose();
    _passwordActualController.dispose();
    _passwordNuevaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 560),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE1E6ED)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          size: 64,
                          color: Color(0xFFFF9800),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Datos Personales',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _cedulaController,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          decoration: const InputDecoration(
                            labelText: 'Cédula',
                            prefixIcon: Icon(Icons.badge_outlined),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: TextEditingController(
                            text: _estudiante?.correo ?? '',
                          ),
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const Divider(height: 32),
                        const Text(
                          'Cambiar Contraseña',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordActualController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña actual',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordNuevaController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Nueva contraseña (opcional)',
                            prefixIcon: Icon(Icons.lock_reset_rounded),
                            hintText: 'Mínimo 6 caracteres',
                          ),
                        ),
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: _guardando ? null : _guardarCambios,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _guardando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Guardar Cambios',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _eliminarCuenta,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade400),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Eliminar Cuenta'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}