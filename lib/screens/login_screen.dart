import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../screens/acerca_de_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _ocultarClave = true;
  bool _recordar = false;
  bool _cargando = false;

  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _cargarCredencialesGuardadas();
  }

  Future<void> _cargarCredencialesGuardadas() async {
    final prefs = await SharedPreferences.getInstance();
    final correo = prefs.getString('recordar_correo') ?? '';
    final password = prefs.getString('recordar_password') ?? '';
    setState(() {
      _correoController.text = correo;
      _passwordController.text = password;
      _recordar = correo.isNotEmpty;
    });
  }

  Future<void> _login() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      _mostrarMensaje('Complete todos los campos', esError: true);
      return;
    }

    setState(() => _cargando = true);

    final estudiante = await _storage.loginEstudiante(correo, password);

    setState(() => _cargando = false);

    if (estudiante == null) {
      _mostrarMensaje('Correo o contraseña incorrectos', esError: true);
      return;
    }

    // Guardar sesión
    await _storage.guardarSesion(
      estudiante.id!,
      estudiante.nombre,
      estudiante.rol,
      estudiante.correo,
    );

    // Guardar credenciales si "recordar" está marcado
    final prefs = await SharedPreferences.getInstance();
    if (_recordar) {
      await prefs.setString('recordar_correo', correo);
      await prefs.setString('recordar_password', password);
    } else {
      await prefs.remove('recordar_correo');
      await prefs.remove('recordar_password');
    }

    _mostrarMensaje('¡Bienvenido, ${estudiante.nombre}!');
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
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
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE3F2FD),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 42,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'EduTask',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17324D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Organiza tus actividades académicas',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF667085)),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'correo@ejemplo.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: _ocultarClave,
                      onSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: '••••••',
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
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _recordar,
                          onChanged: (value) {
                            setState(() => _recordar = value ?? false);
                          },
                          activeColor: const Color(0xFF1565C0),
                        ),
                        const Text('Mantener sesión iniciada'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _cargando ? null : _login,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: const Color(0xFF1565C0),
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
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/registro'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Crear una cuenta'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AcercaDeDialog(),
                        );
                      },
                      child: const Text('Acerca de'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Grupo 1 • Proyecto EduTask',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF98A2B3),
                      ),
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