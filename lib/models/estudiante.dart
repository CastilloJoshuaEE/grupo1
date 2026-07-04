class Estudiante {
  int? id;
  String nombre;
  String correo;
  String password;
  String cedula;
  String rol;
  bool activo;

  Estudiante({
    this.id,
    required this.nombre,
    required this.correo,
    required this.password,
    required this.cedula,
    this.rol = 'estudiante',
    this.activo = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'correo': correo,
    'password': password,
    'cedula': cedula,
    'rol': rol,
    'activo': activo,
  };

  factory Estudiante.fromJson(Map<String, dynamic> json) => Estudiante(
    id: json['id'],
    nombre: json['nombre'] ?? '',
    correo: json['correo'] ?? '',
    password: json['password'] ?? '',
    cedula: json['cedula'] ?? '',
    rol: json['rol'] ?? 'estudiante',
    activo: json['activo'] ?? true,
  );

  Estudiante copyWith({
    int? id,
    String? nombre,
    String? correo,
    String? password,
    String? cedula,
    String? rol,
    bool? activo,
  }) {
    return Estudiante(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      password: password ?? this.password,
      cedula: cedula ?? this.cedula,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
    );
  }
}