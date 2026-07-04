class Recordatorio {
  int? id;
  String mensaje;
  String fecha;
  String hora;
  int estudianteId;

  Recordatorio({
    this.id,
    required this.mensaje,
    required this.fecha,
    required this.hora,
    required this.estudianteId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'mensaje': mensaje,
    'fecha': fecha,
    'hora': hora,
    'estudianteId': estudianteId,
  };

  factory Recordatorio.fromJson(Map<String, dynamic> json) => Recordatorio(
    id: json['id'],
    mensaje: json['mensaje'] ?? '',
    fecha: json['fecha'] ?? '',
    hora: json['hora'] ?? '',
    estudianteId: json['estudianteId'] ?? 0,
  );

  Recordatorio copyWith({
    int? id,
    String? mensaje,
    String? fecha,
    String? hora,
    int? estudianteId,
  }) {
    return Recordatorio(
      id: id ?? this.id,
      mensaje: mensaje ?? this.mensaje,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      estudianteId: estudianteId ?? this.estudianteId,
    );
  }
}