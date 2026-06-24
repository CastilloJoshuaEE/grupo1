import 'package:flutter/material.dart';

class MyHomePageVentanaLogin extends StatefulWidget {
  const MyHomePageVentanaLogin({super.key, required this.title});

  final String title;

  @override
  State<MyHomePageVentanaLogin> createState() =>
      _MyHomePageStateVentanaLogin();
}

class _MyHomePageStateVentanaLogin
    extends State<MyHomePageVentanaLogin> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();

  final String usuarioValido = 'admin@fifa.com';
  final String claveValida = 'fifa2026';
  bool _ocultarClave = true;

  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  void validarInicioSesion() {
    final String correo = _correoController.text.trim();
    final String clave = _claveController.text.trim();

    if (correo.isEmpty || clave.isEmpty) {
      _mostrarMensaje('Complete todos los campos', esError: true);
      return;
    }

    if (correo == usuarioValido && clave == claveValida) {
      Navigator.pushReplacementNamed(context, 'principal');
      return;
    }

    _mostrarMensaje('Correo o contraseña incorrectos', esError: true);
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor:
              esError ? Colors.red.shade700 : const Color(0xFF2E7D32),
        ),
      );
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
                        hintText: 'admin@fifa.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _claveController,
                      obscureText: _ocultarClave,
                      onSubmitted: (_) => validarInicioSesion(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'fifa2026',
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
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: validarInicioSesion,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Ingresar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, 'registro'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Crear una cuenta'),
                    ),
                    const SizedBox(height: 16),
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
