import 'package:flutter/material.dart';
import 'package:fifa/views/ventanaRegistro.dart';

class MyHomePageVentanaPrincipal extends StatefulWidget {
  const MyHomePageVentanaPrincipal({super.key});

  @override
  State<MyHomePageVentanaPrincipal> createState() =>
      _MyHomePageVentanaPrincipalState();
}

class _MyHomePageVentanaPrincipalState
    extends State<MyHomePageVentanaPrincipal> {
  static const Color _colorPrimario = Color(0xFF1565C0);
  static const Color _colorSecundario = Color(0xFF2E7D32);
  static const Color _colorAccent = Color(0xFFFFC107);

  int _indiceSeleccionado = 0;
  late final List<Widget> _pantallas;

  final List<String> _titulos = const [
    'Inicio',
    'Registro',
    'Tareas',
    'Perfil',
  ];

  @override
  void initState() {
    super.initState();
    _pantallas = [
      _InicioEduTask(
        onAbrirRegistro: () => _seleccionarOpcion(1),
        onAbrirTareas: () => _seleccionarOpcion(2),
        onAbrirPerfil: () => _seleccionarOpcion(3),
      ),
      const MyHomePageVentanaRegistro(integradoEnNavigationBar: true),
      const _FormularioProximo(
        icono: Icons.task_alt_rounded,
        titulo: 'Mis tareas',
        descripcion:
            'Aquí se integrará el formulario de tareas del proyecto EduTask.',
      ),
      const _FormularioProximo(
        icono: Icons.person_rounded,
        titulo: 'Mi perfil',
        descripcion:
            'Aquí se integrará el formulario de perfil del proyecto EduTask.',
      ),
    ];
  }

  void _seleccionarOpcion(int indice) {
    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  void _cerrarSesion() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _colorPrimario,
        foregroundColor: Colors.white,
        title: Text(
          'EduTask • ${_titulos[_indiceSeleccionado]}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: IndexedStack(
        index: _indiceSeleccionado,
        children: _pantallas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSeleccionado,
        onDestinationSelected: _seleccionarOpcion,
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: _colorAccent.withOpacity(0.35),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: _colorPrimario),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_add_alt_outlined),
            selectedIcon: Icon(
              Icons.person_add_alt_1_rounded,
              color: _colorSecundario,
            ),
            label: 'Registro',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt_rounded, color: _colorPrimario),
            label: 'Tareas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: _colorPrimario),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _InicioEduTask extends StatelessWidget {
  const _InicioEduTask({
    required this.onAbrirRegistro,
    required this.onAbrirTareas,
    required this.onAbrirPerfil,
  });

  final VoidCallback onAbrirRegistro;
  final VoidCallback onAbrirTareas;
  final VoidCallback onAbrirPerfil;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                  SizedBox(height: 18),
                  Text(
                    '¡Bienvenido a EduTask!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Organiza tus tareas, apuntes y recordatorios desde un solo lugar.',
                    style: TextStyle(
                      color: Color(0xFFE3F2FD),
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Accesos principales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _AccesoCard(
              icono: Icons.person_add_alt_1_rounded,
              titulo: 'Registrar estudiante',
              descripcion: 'Abre el formulario de registro existente.',
              color: const Color(0xFF2E7D32),
              onTap: onAbrirRegistro,
            ),
            const SizedBox(height: 12),
            _AccesoCard(
              icono: Icons.task_alt_rounded,
              titulo: 'Mis tareas',
              descripcion: 'Visualiza tus tareas desde un archivo JSON.',
              color: const Color(0xFF1565C0),
              onTap: () {
                Navigator.pushNamed(context, 'json_tareas');  // ← NUEVA NAVEGACIÓN
              },
            ),
            const SizedBox(height: 12),
            _AccesoCard(
              icono: Icons.person_rounded,
              titulo: 'Mi perfil',
              descripcion: 'Próximo formulario del proyecto EduTask.',
              color: const Color(0xFFFFA000),
              onTap: onAbrirPerfil,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccesoCard extends StatelessWidget {
  const _AccesoCard({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE1E6ED)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icono, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormularioProximo extends StatelessWidget {
  const _FormularioProximo({
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE1E6ED)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  size: 40,
                  color: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                descripcion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
