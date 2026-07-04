import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/estudiante.dart';
import '../models/tarea.dart';
import '../models/apunte.dart';
import '../models/categoria.dart';
import '../models/recordatorio.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Claves para SharedPreferences
  static const String _keyEstudiantes = 'estudiantes';
  static const String _keyTareas = 'tareas';
  static const String _keyApuntes = 'apuntes';
  static const String _keyCategorias = 'categorias';
  static const String _keyRecordatorios = 'recordatorios';
  static const String _keySessionEstudianteId = 'session_estudiante_id';
  static const String _keySessionNombre = 'session_nombre';
  static const String _keySessionRol = 'session_rol';
  static const String _keySessionCorreo = 'session_correo';

  // ==================== MÉTODOS AUXILIARES ====================

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  Future<void> _guardarLista<T>(String key, List<T> items, 
      Map<String, dynamic> Function(T) toJson) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => toJson(item)).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<T>> _cargarLista<T>(String key, 
      T Function(Map<String, dynamic>) fromJson) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null || jsonString.isEmpty) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  int _generarId(List<dynamic> items) {
    if (items.isEmpty) return 1;
    final maxId = items.map((item) => item.id ?? 0).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  // ==================== ESTUDIANTES ====================

  Future<List<Estudiante>> getEstudiantes() async {
    return await _cargarLista(_keyEstudiantes, Estudiante.fromJson);
  }

  Future<void> guardarEstudiantes(List<Estudiante> estudiantes) async {
    await _guardarLista(_keyEstudiantes, estudiantes, (e) => e.toJson());
  }

  Future<Estudiante?> loginEstudiante(String correo, String password) async {
    final estudiantes = await getEstudiantes();
    try {
      return estudiantes.firstWhere(
        (e) => e.correo == correo && e.password == password && e.activo,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> correoExiste(String correo) async {
    final estudiantes = await getEstudiantes();
    return estudiantes.any((e) => e.correo == correo);
  }

  Future<Estudiante?> getEstudianteById(int id) async {
    final estudiantes = await getEstudiantes();
    try {
      return estudiantes.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<int> insertarEstudiante(Estudiante estudiante) async {
    final estudiantes = await getEstudiantes();
    final nuevoId = _generarId(estudiantes);
    final nuevoEstudiante = estudiante.copyWith(id: nuevoId);
    estudiantes.add(nuevoEstudiante);
    await guardarEstudiantes(estudiantes);
    return nuevoId;
  }

  Future<bool> actualizarEstudiante(Estudiante estudiante) async {
    final estudiantes = await getEstudiantes();
    final index = estudiantes.indexWhere((e) => e.id == estudiante.id);
    if (index == -1) return false;
    estudiantes[index] = estudiante;
    await guardarEstudiantes(estudiantes);
    return true;
  }

  Future<bool> desactivarEstudiante(int id) async {
    final estudiantes = await getEstudiantes();
    final index = estudiantes.indexWhere((e) => e.id == id);
    if (index == -1) return false;
    estudiantes[index] = estudiantes[index].copyWith(activo: false);
    await guardarEstudiantes(estudiantes);
    return true;
  }

  Future<List<Estudiante>> getEstudiantesActivos() async {
    final estudiantes = await getEstudiantes();
    return estudiantes.where((e) => e.activo).toList();
  }

  Future<List<Estudiante>> buscarEstudiantePorCedula(String cedula) async {
    final estudiantes = await getEstudiantesActivos();
    return estudiantes.where((e) => e.cedula == cedula).toList();
  }

  // ==================== SESIÓN ====================

  Future<void> guardarSesion(int id, String nombre, String rol, String correo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySessionEstudianteId, id);
    await prefs.setString(_keySessionNombre, nombre);
    await prefs.setString(_keySessionRol, rol);
    await prefs.setString(_keySessionCorreo, correo);
  }

  Future<Map<String, dynamic>> obtenerSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt(_keySessionEstudianteId) ?? -1,
      'nombre': prefs.getString(_keySessionNombre) ?? '',
      'rol': prefs.getString(_keySessionRol) ?? 'estudiante',
      'correo': prefs.getString(_keySessionCorreo) ?? '',
    };
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySessionEstudianteId);
    await prefs.remove(_keySessionNombre);
    await prefs.remove(_keySessionRol);
    await prefs.remove(_keySessionCorreo);
  }

  Future<int> getEstudianteIdSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySessionEstudianteId) ?? -1;
  }

  // ==================== CATEGORÍAS ====================

  Future<List<Categoria>> getCategorias({int? estudianteId}) async {
    final categorias = await _cargarLista(_keyCategorias, Categoria.fromJson);
    if (estudianteId == null) return categorias;
    return categorias.where((c) => 
        c.estudianteId == null || c.estudianteId == estudianteId).toList();
  }

  Future<void> guardarCategorias(List<Categoria> categorias) async {
    await _guardarLista(_keyCategorias, categorias, (c) => c.toJson());
  }

  Future<int> insertarCategoria(Categoria categoria) async {
    final categorias = await _cargarLista(_keyCategorias, Categoria.fromJson);
    final nuevoId = _generarId(categorias);
    final nuevaCategoria = categoria.copyWith(id: nuevoId);
    categorias.add(nuevaCategoria);
    await guardarCategorias(categorias);
    return nuevoId;
  }

  Future<bool> actualizarCategoria(Categoria categoria) async {
    final categorias = await _cargarLista(_keyCategorias, Categoria.fromJson);
    final index = categorias.indexWhere((c) => c.id == categoria.id);
    if (index == -1) return false;
    categorias[index] = categoria;
    await guardarCategorias(categorias);
    return true;
  }

  Future<bool> eliminarCategoria(int id) async {
    final categorias = await _cargarLista(_keyCategorias, Categoria.fromJson);
    final newList = categorias.where((c) => c.id != id).toList();
    if (newList.length == categorias.length) return false;
    await guardarCategorias(newList);
    return true;
  }

  Future<int> getIdCategoriaPorNombre(String nombre, int estudianteId) async {
    final categorias = await getCategorias(estudianteId: estudianteId);
    final match = categorias.firstWhere(
      (c) => c.nombre == nombre,
      orElse: () => Categoria(id: -1, nombre: '', estudianteId: estudianteId),
    );
    return match.id ?? -1;
  }

  Future<List<String>> getNombresCategorias(int estudianteId) async {
    final categorias = await getCategorias(estudianteId: estudianteId);
    return categorias.map((c) => c.nombre).toList();
  }

  // ==================== TAREAS ====================

  Future<List<Tarea>> getTareas({int? estudianteId}) async {
    final tareas = await _cargarLista(_keyTareas, Tarea.fromJson);
    if (estudianteId == null) return tareas;
    return tareas.where((t) => t.estudianteId == estudianteId).toList();
  }

  Future<void> guardarTareas(List<Tarea> tareas) async {
    await _guardarLista(_keyTareas, tareas, (t) => t.toJson());
  }

  Future<List<Tarea>> getTareasFiltradas(int estudianteId, bool completadas) async {
    final tareas = await getTareas(estudianteId: estudianteId);
    return tareas.where((t) => t.completada == completadas).toList();
  }

  Future<List<Tarea>> getTareasPorCategoria(int estudianteId, int categoriaId) async {
    final tareas = await getTareas(estudianteId: estudianteId);
    return tareas.where((t) => t.categoriaId == categoriaId).toList();
  }

  Future<int> insertarTarea(Tarea tarea) async {
    final tareas = await _cargarLista(_keyTareas, Tarea.fromJson);
    final nuevoId = _generarId(tareas);
    final nuevaTarea = tarea.copyWith(id: nuevoId);
    tareas.add(nuevaTarea);
    await guardarTareas(tareas);
    return nuevoId;
  }

  Future<bool> actualizarTarea(Tarea tarea) async {
    final tareas = await _cargarLista(_keyTareas, Tarea.fromJson);
    final index = tareas.indexWhere((t) => t.id == tarea.id);
    if (index == -1) return false;
    tareas[index] = tarea;
    await guardarTareas(tareas);
    return true;
  }

  Future<bool> marcarTareaCompletada(int id, bool completada) async {
    final tareas = await _cargarLista(_keyTareas, Tarea.fromJson);
    final index = tareas.indexWhere((t) => t.id == id);
    if (index == -1) return false;
    tareas[index] = tareas[index].copyWith(completada: completada);
    await guardarTareas(tareas);
    return true;
  }

  Future<bool> eliminarTarea(int id) async {
    final tareas = await _cargarLista(_keyTareas, Tarea.fromJson);
    final newList = tareas.where((t) => t.id != id).toList();
    if (newList.length == tareas.length) return false;
    await guardarTareas(newList);
    return true;
  }

  // ==================== APUNTES ====================

  Future<List<Apunte>> getApuntes({int? estudianteId}) async {
    final apuntes = await _cargarLista(_keyApuntes, Apunte.fromJson);
    if (estudianteId == null) return apuntes;
    return apuntes.where((a) => a.estudianteId == estudianteId).toList();
  }

  Future<void> guardarApuntes(List<Apunte> apuntes) async {
    await _guardarLista(_keyApuntes, apuntes, (a) => a.toJson());
  }

  Future<List<Apunte>> getApuntesPorCategoria(int estudianteId, int categoriaId) async {
    final apuntes = await getApuntes(estudianteId: estudianteId);
    return apuntes.where((a) => a.categoriaId == categoriaId).toList();
  }

  Future<int> insertarApunte(Apunte apunte) async {
    final apuntes = await _cargarLista(_keyApuntes, Apunte.fromJson);
    final nuevoId = _generarId(apuntes);
    final nuevoApunte = apunte.copyWith(id: nuevoId);
    apuntes.add(nuevoApunte);
    await guardarApuntes(apuntes);
    return nuevoId;
  }

  Future<bool> actualizarApunte(Apunte apunte) async {
    final apuntes = await _cargarLista(_keyApuntes, Apunte.fromJson);
    final index = apuntes.indexWhere((a) => a.id == apunte.id);
    if (index == -1) return false;
    apuntes[index] = apunte;
    await guardarApuntes(apuntes);
    return true;
  }

  Future<bool> eliminarApunte(int id) async {
    final apuntes = await _cargarLista(_keyApuntes, Apunte.fromJson);
    final newList = apuntes.where((a) => a.id != id).toList();
    if (newList.length == apuntes.length) return false;
    await guardarApuntes(newList);
    return true;
  }

  // ==================== RECORDATORIOS ====================

  Future<List<Recordatorio>> getRecordatorios({int? estudianteId}) async {
    final recordatorios = await _cargarLista(_keyRecordatorios, Recordatorio.fromJson);
    if (estudianteId == null) return recordatorios;
    return recordatorios.where((r) => r.estudianteId == estudianteId).toList();
  }

  Future<void> guardarRecordatorios(List<Recordatorio> recordatorios) async {
    await _guardarLista(_keyRecordatorios, recordatorios, (r) => r.toJson());
  }

  Future<int> insertarRecordatorio(Recordatorio recordatorio) async {
    final recordatorios = await _cargarLista(_keyRecordatorios, Recordatorio.fromJson);
    final nuevoId = _generarId(recordatorios);
    final nuevoRecordatorio = recordatorio.copyWith(id: nuevoId);
    recordatorios.add(nuevoRecordatorio);
    await guardarRecordatorios(recordatorios);
    return nuevoId;
  }

  Future<bool> actualizarRecordatorio(Recordatorio recordatorio) async {
    final recordatorios = await _cargarLista(_keyRecordatorios, Recordatorio.fromJson);
    final index = recordatorios.indexWhere((r) => r.id == recordatorio.id);
    if (index == -1) return false;
    recordatorios[index] = recordatorio;
    await guardarRecordatorios(recordatorios);
    return true;
  }

  Future<bool> eliminarRecordatorio(int id) async {
    final recordatorios = await _cargarLista(_keyRecordatorios, Recordatorio.fromJson);
    final newList = recordatorios.where((r) => r.id != id).toList();
    if (newList.length == recordatorios.length) return false;
    await guardarRecordatorios(newList);
    return true;
  }

  // ==================== DATOS DE PRUEBA ====================

  Future<void> cargarDatosIniciales() async {
    // Verificar si ya hay estudiantes
    final estudiantes = await getEstudiantes();
    if (estudiantes.isNotEmpty) return;

    // Crear estudiante administrador por defecto
    final admin = Estudiante(
      nombre: 'Administrador',
      correo: 'admin@edutask.com',
      password: 'admin123',
      cedula: '1234567890',
      rol: 'administrador',
    );
    await insertarEstudiante(admin);

    // Crear categorías por defecto
    final categoriasDefault = [
      Categoria(nombre: 'Matemáticas', color: '#F44336'),
      Categoria(nombre: 'Programación', color: '#2196F3'),
      Categoria(nombre: 'Ciencias', color: '#4CAF50'),
      Categoria(nombre: 'Historia', color: '#FF9800'),
      Categoria(nombre: 'Inglés', color: '#9C27B0'),
    ];
    
    for (var cat in categoriasDefault) {
      await insertarCategoria(cat);
    }
  }
}