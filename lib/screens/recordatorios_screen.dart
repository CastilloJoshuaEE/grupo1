import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/recordatorio.dart';
import '../widgets/recordatorio_card.dart';

class RecordatoriosScreen extends StatefulWidget {
  const RecordatoriosScreen({super.key});

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> {
  List<Recordatorio> _recordatorios = [];
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
    await _cargarRecordatorios();
    if (mounted) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cargarRecordatorios() async {
    final recordatorios = await _storage.getRecordatorios(
      estudianteId: _estudianteId,
    );
    if (mounted) {
      setState(() {
        _recordatorios = recordatorios;
      });
    }
  }

  Future<void> _mostrarFormulario({Recordatorio? recordatorioExistente}) async {
    final formKey = GlobalKey<FormState>();
    final mensajeController = TextEditingController(
      text: recordatorioExistente?.mensaje,
    );
    
    DateTime? fechaSeleccionada;
    TimeOfDay? horaSeleccionada;

    if (recordatorioExistente != null) {
      try {
        final parts = recordatorioExistente.fecha.split('/');
        if (parts.length == 3) {
          fechaSeleccionada = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]) - 1,
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
      
      try {
        final parts = recordatorioExistente.hora.split(':');
        if (parts.length == 2) {
          horaSeleccionada = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      } catch (_) {}
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(recordatorioExistente == null ? 'Nuevo Recordatorio' : 'Editar Recordatorio'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: mensajeController,
                      decoration: const InputDecoration(
                        labelText: 'Mensaje',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese un mensaje';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: fechaSeleccionada ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setStateDialog(() {
                            fechaSeleccionada = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          fechaSeleccionada == null
                              ? 'Seleccione una fecha'
                              : DateFormat('dd/MM/yyyy').format(fechaSeleccionada!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: horaSeleccionada ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setStateDialog(() {
                            horaSeleccionada = time;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          horaSeleccionada == null
                              ? 'Seleccione una hora'
                              : horaSeleccionada!.format(context),
                        ),
                      ),
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
                    if (fechaSeleccionada == null) {
                      _mostrarMensaje('Seleccione una fecha', esError: true);
                      return;
                    }
                    if (horaSeleccionada == null) {
                      _mostrarMensaje('Seleccione una hora', esError: true);
                      return;
                    }
                    Navigator.pop(context, {
                      'mensaje': mensajeController.text.trim(),
                      'fecha': DateFormat('dd/MM/yyyy').format(fechaSeleccionada!),
                      'hora': '${horaSeleccionada!.hour.toString().padLeft(2, '0')}:'
                          '${horaSeleccionada!.minute.toString().padLeft(2, '0')}',
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

    if (recordatorioExistente == null) {
      final recordatorio = Recordatorio(
        mensaje: result['mensaje'],
        fecha: result['fecha'],
        hora: result['hora'],
        estudianteId: _estudianteId,
      );
      await _storage.insertarRecordatorio(recordatorio);
    } else {
      final recordatorioActualizado = Recordatorio(
        id: recordatorioExistente.id,
        mensaje: result['mensaje'],
        fecha: result['fecha'],
        hora: result['hora'],
        estudianteId: _estudianteId,
      );
      await _storage.actualizarRecordatorio(recordatorioActualizado);
    }

    await _cargarRecordatorios();
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

  Future<void> _eliminarRecordatorio(Recordatorio recordatorio) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar recordatorio'),
        content: Text('¿Eliminar este recordatorio?'),
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
      await _storage.eliminarRecordatorio(recordatorio.id!);
      await _cargarRecordatorios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recordatorios'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _recordatorios.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_rounded,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay recordatorios',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca el botón + para agregar un recordatorio',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _recordatorios.length,
                  itemBuilder: (context, index) {
                    final recordatorio = _recordatorios[index];
                    return RecordatorioCard(
                      recordatorio: recordatorio,
                      onEdit: () => _mostrarFormulario(
                        recordatorioExistente: recordatorio,
                      ),
                      onDelete: () => _eliminarRecordatorio(recordatorio),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFFE65100),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}