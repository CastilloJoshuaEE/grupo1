class Categoria {
  int? id;
  String nombre;
  String color;
  int? estudianteId;

  Categoria({
    this.id,
    required this.nombre,
    this.color = '#2196F3',
    this.estudianteId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'color': color,
    'estudianteId': estudianteId,
  };

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
    id: json['id'],
    nombre: json['nombre'] ?? '',
    color: json['color'] ?? '#2196F3',
    estudianteId: json['estudianteId'],
  );

  Categoria copyWith({
    int? id,
    String? nombre,
    String? color,
    int? estudianteId,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      estudianteId: estudianteId ?? this.estudianteId,
    );
  }
}