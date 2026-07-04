import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../screens/acerca_de_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _nombre = 'Estudiante';
  String _rol = 'estudiante';
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final sesion = await _storage.obtenerSesion();
    if (mounted) {
      setState(() {
        _nombre = sesion['nombre'] ?? 'Estudiante';
        _rol = sesion['rol'] ?? 'estudiante';
      });
    }
  }

  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _storage.cerrarSesion();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduTask'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school_rounded, size: 40, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    _nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'EduTask',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(
                    icon: Icons.task_alt_rounded,
                    title: 'Mis Tareas',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/tareas');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.note_alt_rounded,
                    title: 'Mis Apuntes',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/apuntes');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_rounded,
                    title: 'Mis Recordatorios',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/recordatorios');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_rounded,
                    title: 'Mi Perfil',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/perfil');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.category_rounded,
                    title: 'Categorías',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/categorias');
                    },
                  ),
                  if (_rol == 'administrador')
                    _buildDrawerItem(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Administrar Estudiantes',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/admin_estudiantes');
                      },
                    ),
                  const Divider(),
                  _buildDrawerItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Acerca de',
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => const AcercaDeDialog(),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.logout_rounded,
                    title: 'Cerrar Sesión',
                    onTap: () {
                      Navigator.pop(context);
                      _cerrarSesion();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
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
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.school_rounded, size: 42, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      '¡Hola, $_nombre!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
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
              _buildCard(
                icon: Icons.task_alt_rounded,
                title: 'Mis Tareas',
                subtitle: 'Organiza tus tareas académicas',
                color: const Color(0xFF1565C0),
                onTap: () => Navigator.pushNamed(context, '/tareas'),
              ),
              const SizedBox(height: 12),
              _buildCard(
                icon: Icons.note_alt_rounded,
                title: 'Mis Apuntes',
                subtitle: 'Notas y apuntes de clase',
                color: const Color(0xFF2E7D32),
                onTap: () => Navigator.pushNamed(context, '/apuntes'),
              ),
              const SizedBox(height: 12),
              _buildCard(
                icon: Icons.notifications_rounded,
                title: 'Mis Recordatorios',
                subtitle: 'Alertas para actividades importantes',
                color: const Color(0xFFE65100),
                onTap: () => Navigator.pushNamed(context, '/recordatorios'),
              ),
              const SizedBox(height: 12),
              _buildCard(
                icon: Icons.person_rounded,
                title: 'Mi Perfil',
                subtitle: 'Ver y editar datos personales',
                color: const Color(0xFFFF9800),
                onTap: () => Navigator.pushNamed(context, '/perfil'),
              ),
              if (_rol == 'administrador') ...[
                const SizedBox(height: 12),
                _buildCard(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Administrar Estudiantes',
                  subtitle: 'Gestionar usuarios del sistema',
                  color: const Color(0xFF9C27B0),
                  onTap: () => Navigator.pushNamed(context, '/admin_estudiantes'),
                ),
              ],
              const SizedBox(height: 12),
              _buildCard(
                icon: Icons.logout_rounded,
                title: 'Cerrar Sesión',
                subtitle: 'Salir de la aplicación',
                color: Colors.red.shade700,
                onTap: _cerrarSesion,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 13,
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