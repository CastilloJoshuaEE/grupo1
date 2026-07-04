class Tarea {
  int? id;
  String titulo;
  String descripcion;
  String fechaEntrega;
  String prioridad;
  bool completada;
  int categoriaId;
  String? categoriaNombre;
  int estudianteId;

  Tarea({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaEntrega,
    required this.prioridad,
    this.completada = false,
    required this.categoriaId,
    this.categoriaNombre,
    required this.estudianteId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'fechaEntrega': fechaEntrega,
    'prioridad': prioridad,
    'completada': completada,
    'categoriaId': categoriaId,
    'categoriaNombre': categoriaNombre,
    'estudianteId': estudianteId,
  };

  factory Tarea.fromJson(Map<String, dynamic> json) => Tarea(
    id: json['id'],
    titulo: json['titulo'] ?? '',
    descripcion: json['descripcion'] ?? '',
    fechaEntrega: json['fechaEntrega'] ?? '',
    prioridad: json['prioridad'] ?? 'Media',
    completada: json['completada'] ?? false,
    categoriaId: json['categoriaId'] ?? 0,
    categoriaNombre: json['categoriaNombre'],
    estudianteId: json['estudianteId'] ?? 0,
  );

  Tarea copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    String? fechaEntrega,
    String? prioridad,
    bool? completada,
    int? categoriaId,
    String? categoriaNombre,
    int? estudianteId,
  }) {
    return Tarea(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      prioridad: prioridad ?? this.prioridad,
      completada: completada ?? this.completada,
      categoriaId: categoriaId ?? this.categoriaId,
      categoriaNombre: categoriaNombre ?? this.categoriaNombre,
      estudianteId: estudianteId ?? this.estudianteId,
    );
  }
}