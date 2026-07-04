class Apunte {
  int? id;
  String titulo;
  String contenido;
  String fecha;
  int categoriaId;
  String? categoriaNombre;
  int? tareaId;
  int estudianteId;

  Apunte({
    this.id,
    required this.titulo,
    required this.contenido,
    required this.fecha,
    required this.categoriaId,
    this.categoriaNombre,
    this.tareaId,
    required this.estudianteId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'contenido': contenido,
    'fecha': fecha,
    'categoriaId': categoriaId,
    'categoriaNombre': categoriaNombre,
    'tareaId': tareaId,
    'estudianteId': estudianteId,
  };

  factory Apunte.fromJson(Map<String, dynamic> json) => Apunte(
    id: json['id'],
    titulo: json['titulo'] ?? '',
    contenido: json['contenido'] ?? '',
    fecha: json['fecha'] ?? '',
    categoriaId: json['categoriaId'] ?? 0,
    categoriaNombre: json['categoriaNombre'],
    tareaId: json['tareaId'],
    estudianteId: json['estudianteId'] ?? 0,
  );

  Apunte copyWith({
    int? id,
    String? titulo,
    String? contenido,
    String? fecha,
    int? categoriaId,
    String? categoriaNombre,
    int? tareaId,
    int? estudianteId,
  }) {
    return Apunte(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      fecha: fecha ?? this.fecha,
      categoriaId: categoriaId ?? this.categoriaId,
      categoriaNombre: categoriaNombre ?? this.categoriaNombre,
      tareaId: tareaId ?? this.tareaId,
      estudianteId: estudianteId ?? this.estudianteId,
    );
  }
}