import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/estudiante.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();
  final _cedulaController = TextEditingController();
  
  String _rolSeleccionado = 'estudiante';
  DateTime? _fechaNacimiento;
  bool _ocultarClave = true;
  bool _ocultarConfirmacion = true;
  bool _cargando = false;

  final StorageService _storage = StorageService();

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _confirmarController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecciona la fecha de nacimiento',
    );
    if (fecha != null) {
      setState(() => _fechaNacimiento = fecha);
    }
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaNacimiento == null) {
      _mostrarMensaje('Seleccione la fecha de nacimiento', esError: true);
      return;
    }

    setState(() => _cargando = true);

    final nombre = _nombreController.text.trim();
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();
    final cedula = _cedulaController.text.trim();

    // Verificar si el correo ya existe
    final existe = await _storage.correoExiste(correo);
    if (existe) {
      setState(() => _cargando = false);
      _mostrarMensaje('El correo ya está registrado', esError: true);
      return;
    }

    final estudiante = Estudiante(
      nombre: nombre,
      correo: correo,
      password: password,
      cedula: cedula,
      rol: _rolSeleccionado,
    );

    final id = await _storage.insertarEstudiante(estudiante);
    setState(() => _cargando = false);

    if (id > 0) {
      _mostrarMensaje('¡Registro exitoso! Ya puede iniciar sesión.');
      if (mounted) Navigator.pop(context);
    } else {
      _mostrarMensaje('Error al registrar', esError: true);
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
        title: const Text('Registro'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 48,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Crear cuenta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17324D),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
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
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _ocultarClave,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Mínimo 6 caracteres',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => _ocultarClave = !_ocultarClave);
                          },
                          icon: Icon(
                            _ocultarClave
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese una contraseña';
                        }
                        if (value.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmarController,
                      obscureText: _ocultarConfirmacion,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: const Icon(Icons.lock_reset_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _ocultarConfirmacion = !_ocultarConfirmacion;
                            });
                          },
                          icon: Icon(
                            _ocultarConfirmacion
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirme la contraseña';
                        }
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _cedulaController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Cédula',
                        hintText: 'Opcional - 10 dígitos',
                        prefixIcon: Icon(Icons.badge_outlined),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length != 10) {
                          return 'La cédula debe tener 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _rolSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'estudiante', child: Text('Estudiante')),
                        DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                      ],
                      onChanged: (value) {
                        setState(() => _rolSeleccionado = value!);
                      },
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _seleccionarFecha,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de nacimiento',
                          prefixIcon: Icon(Icons.calendar_month_outlined),
                        ),
                        child: Text(
                          _fechaNacimiento == null
                              ? 'Seleccione una fecha'
                              : DateFormat('dd/MM/yyyy').format(_fechaNacimiento!),
                          style: TextStyle(
                            color: _fechaNacimiento == null
                                ? Colors.grey.shade500
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: _cargando ? null : _registrar,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _cargando
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
                              'Registrarse',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}