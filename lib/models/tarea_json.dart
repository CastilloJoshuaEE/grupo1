class TareaJson {
  final String titulo;
  final String descripcion;
  final String fechaEntrega;
  final String prioridad;
  final String categoria;
  final bool completada;

  TareaJson({
    required this.titulo,
    required this.descripcion,
    required this.fechaEntrega,
    required this.prioridad,
    required this.categoria,
    required this.completada,
  });

  factory TareaJson.fromJson(Map<String, dynamic> json) {
    return TareaJson(
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fechaEntrega: json['fechaEntrega'] ?? '',
      prioridad: json['prioridad'] ?? '',
      categoria: json['categoria'] ?? '',
      completada: json['completada'] ?? false,
    );
  }
}