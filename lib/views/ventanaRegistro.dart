import 'package:flutter/material.dart';

class MyHomePageVentanaRegistro extends StatefulWidget {
  const MyHomePageVentanaRegistro({
    super.key,
    this.integradoEnNavigationBar = false,
  });

  final bool integradoEnNavigationBar;

  @override
  State<MyHomePageVentanaRegistro> createState() =>
      _MyHomePageVentanaRegistroState();
}

class _MyHomePageVentanaRegistroState
    extends State<MyHomePageVentanaRegistro> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();
  final TextEditingController _confirmarClaveController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  DateTime? _fechaNacimiento;
  String _paisSeleccionado = 'Ecuador';
  String _generoSeleccionado = 'Masculino';
  bool _ocultarClave = true;
  bool _ocultarConfirmacion = true;

  final List<String> _paises = const [
    'Ecuador',
    'Argentina',
    'Brasil',
    'Chile',
    'Colombia',
    'Perú',
    'Uruguay',
    'Paraguay',
    'Bolivia',
    'Venezuela',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _claveController.dispose();
    _confirmarClaveController.dispose();
    _telefonoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime ahora = DateTime.now();
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2005, 1, 1),
      firstDate: DateTime(1900),
      lastDate: ahora,
      helpText: 'Selecciona la fecha de nacimiento',
    );

    if (fecha == null) return;

    setState(() {
      _fechaNacimiento = fecha;
      _fechaController.text =
          '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}';
    });
  }

  String? _validarTextoObligatorio(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingrese $campo';
    }
    return null;
  }

  String? _validarCorreo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingrese el correo electrónico';
    }

    final RegExp correoValido = RegExp(
      r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$',
    );

    if (!correoValido.hasMatch(valor.trim())) {
      return 'Ingrese un correo válido';
    }

    return null;
  }

  String? _validarTelefono(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingrese el teléfono';
    }

    if (!RegExp(r'^\d{10}$').hasMatch(valor.trim())) {
      return 'Ingrese 10 dígitos';
    }

    return null;
  }

  String? _validarClave(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingrese una contraseña';
    }

    if (valor.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }

    return null;
  }

  String? _validarConfirmacion(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Confirme la contraseña';
    }

    if (valor != _claveController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  void _registrarUsuario() {
    FocusScope.of(context).unfocus();

    final bool formularioValido = _formKey.currentState?.validate() ?? false;

    if (_fechaNacimiento == null) {
      _mostrarMensaje('Seleccione la fecha de nacimiento', esError: true);
      return;
    }

    if (!formularioValido) return;

    debugPrint('Registro exitoso:');
    debugPrint('Nombre: ${_nombreController.text} ${_apellidoController.text}');
    debugPrint('Correo: ${_correoController.text}');
    debugPrint('Teléfono: ${_telefonoController.text}');
    debugPrint('Fecha: ${_fechaController.text}');
    debugPrint('País: $_paisSeleccionado');
    debugPrint('Género: $_generoSeleccionado');

    _mostrarMensaje('Estudiante registrado correctamente');
    _limpiarFormulario();

    if (!widget.integradoEnNavigationBar) {
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  void _limpiarFormulario({bool mostrarMensaje = false}) {
    _formKey.currentState?.reset();
    _nombreController.clear();
    _apellidoController.clear();
    _correoController.clear();
    _claveController.clear();
    _confirmarClaveController.clear();
    _telefonoController.clear();
    _fechaController.clear();

    setState(() {
      _fechaNacimiento = null;
      _paisSeleccionado = 'Ecuador';
      _generoSeleccionado = 'Masculino';
    });

    if (mostrarMensaje) {
      _mostrarMensaje('Todos los campos han sido borrados');
    }
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
    final Widget contenido = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE1E6ED)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Color(0xFF1565C0),
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Registro de estudiante',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17324D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Completa la información para crear una cuenta en EduTask.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF667085),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _nombreController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Ingrese el nombre',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (valor) =>
                        _validarTextoObligatorio(valor, 'el nombre'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _apellidoController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      hintText: 'Ingrese el apellido',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (valor) =>
                        _validarTextoObligatorio(valor, 'el apellido'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'ejemplo@correo.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: _validarCorreo,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      hintText: '0999999999',
                      prefixIcon: Icon(Icons.phone_outlined),
                      counterText: '',
                    ),
                    validator: _validarTelefono,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _fechaController,
                    readOnly: true,
                    onTap: _seleccionarFecha,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      hintText: 'Seleccione una fecha',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                      suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _paisSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'País de residencia',
                      prefixIcon: Icon(Icons.public_rounded),
                    ),
                    items: _paises
                        .map(
                          (pais) => DropdownMenuItem<String>(
                            value: pais,
                            child: Text(pais),
                          ),
                        )
                        .toList(),
                    onChanged: (pais) {
                      if (pais == null) return;
                      setState(() => _paisSeleccionado = pais);
                    },
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD7DEE8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Género',
                          style: TextStyle(
                            color: Color(0xFF4A5568),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Wrap(
                          spacing: 4,
                          runSpacing: 0,
                          children: [
                            _OpcionGenero(
                              valor: 'Masculino',
                              seleccionado: _generoSeleccionado,
                              onChanged: (valor) {
                                setState(() => _generoSeleccionado = valor);
                              },
                            ),
                            _OpcionGenero(
                              valor: 'Femenino',
                              seleccionado: _generoSeleccionado,
                              onChanged: (valor) {
                                setState(() => _generoSeleccionado = valor);
                              },
                            ),
                            _OpcionGenero(
                              valor: 'Otro',
                              seleccionado: _generoSeleccionado,
                              onChanged: (valor) {
                                setState(() => _generoSeleccionado = valor);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _claveController,
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
                    validator: _validarClave,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmarClaveController,
                    obscureText: _ocultarConfirmacion,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(
                            () => _ocultarConfirmacion =
                                !_ocultarConfirmacion,
                          );
                        },
                        icon: Icon(
                          _ocultarConfirmacion
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: _validarConfirmacion,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _registrarUsuario,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: const Text(
                            'Aceptar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _limpiarFormulario(mostrarMensaje: true),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade400),
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text(
                            'Borrar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!widget.integradoEnNavigationBar) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Volver al inicio de sesión'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.integradoEnNavigationBar) {
      return contenido;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: contenido,
    );
  }
}

class _OpcionGenero extends StatelessWidget {
  const _OpcionGenero({
    required this.valor,
    required this.seleccionado,
    required this.onChanged,
  });

  final String valor;
  final String seleccionado;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(valor),
      selected: seleccionado == valor,
      onSelected: (_) => onChanged(valor),
    );
  }
}
