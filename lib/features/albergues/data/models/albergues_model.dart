// Relación usuario ↔ albergue
class UsuarioAlbergueModel {
  final int id;
  final String idUsuario;
  final int idAlbergue;
  final String rol;
  final DateTime createdAt;

  UsuarioAlbergueModel({
    required this.id,
    required this.idUsuario,
    required this.idAlbergue,
    required this.rol,
    required this.createdAt,
  });

  factory UsuarioAlbergueModel.fromJson(Map<String, dynamic> json) {
    return UsuarioAlbergueModel(
      id: json['id'] as int,
      idUsuario: json['id_usuario'] as String,
      idAlbergue: json['id_albergue'] as int,
      rol: json['rol'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_usuario': idUsuario,
        'id_albergue': idAlbergue,
        'rol': rol,
        'created_at': createdAt.toIso8601String(),
      };
}

// ============================================

// Relación mascota ↔ albergue
class MascotaAlbergueModel {
  final int id;
  final int idMascota;
  final int idAlbergue;
  final DateTime fechaIngreso;
  final DateTime? fechaSalida;
  final String estado;
  final DateTime createdAt;

  MascotaAlbergueModel({
    required this.id,
    required this.idMascota,
    required this.idAlbergue,
    required this.fechaIngreso,
    this.fechaSalida,
    required this.estado,
    required this.createdAt,
  });

  factory MascotaAlbergueModel.fromJson(Map<String, dynamic> json) {
    return MascotaAlbergueModel(
      id: json['id'] as int,
      idMascota: json['id_mascota'] as int,
      idAlbergue: json['id_albergue'] as int,
      fechaIngreso: DateTime.parse(json['fecha_ingreso'] as String),
      fechaSalida: json['fecha_salida'] != null
          ? DateTime.parse(json['fecha_salida'] as String)
          : null,
      estado: json['estado'] as String? ?? 'activo',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_mascota': idMascota,
        'id_albergue': idAlbergue,
        'fecha_ingreso': fechaIngreso.toIso8601String(),
        'fecha_salida': fechaSalida?.toIso8601String(),
        'estado': estado,
        'created_at': createdAt.toIso8601String(),
      };
}

// ============================================

class AlbergueModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? telefono;
  final String? email;
  final String? imagen;
  final String? ubicacion;
  final double? latitud;
  final double? longitud;
  final bool verificado;
  final String estado;
  final DateTime createdAt;
  // Joins opcionales según el query
  final List<UsuarioAlbergueModel> miembros;
  final List<MascotaAlbergueModel> mascotas;

  AlbergueModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.telefono,
    this.email,
    this.imagen,
    this.ubicacion,
    this.latitud,
    this.longitud,
    required this.verificado,
    required this.estado,
    required this.createdAt,
    this.miembros = const [],
    this.mascotas = const [],
  });

  factory AlbergueModel.fromJson(Map<String, dynamic> json) {
    final miembrosRaw = json['usuario_albergue'] as List<dynamic>? ?? [];
    final mascotasRaw = json['mascota_albergue'] as List<dynamic>? ?? [];

    return AlbergueModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      imagen: json['imagen'] as String?,
      ubicacion: json['ubicacion'] as String?,
      latitud: json['latitud'] != null
          ? double.tryParse(json['latitud'].toString())
          : null,
      longitud: json['longitud'] != null
          ? double.tryParse(json['longitud'].toString())
          : null,
      verificado: json['verificado'] as bool? ?? false,
      estado: json['estado'] as String? ?? 'pendiente',
      createdAt: DateTime.parse(json['created_at'] as String),
      miembros: miembrosRaw
          .map((e) => UsuarioAlbergueModel.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(),
      mascotas: mascotasRaw
          .map((e) => MascotaAlbergueModel.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'telefono': telefono,
        'email': email,
        'imagen': imagen,
        'ubicacion': ubicacion,
        'latitud': latitud,
        'longitud': longitud,
        'verificado': verificado,
        'estado': estado,
        'created_at': createdAt.toIso8601String(),
        'usuario_albergue': miembros.map((e) => e.toJson()).toList(),
        'mascota_albergue': mascotas.map((e) => e.toJson()).toList(),
      };

  // Helper — rol del usuario en este albergue
  String? getRolUsuario(String userId) {
    try {
      return miembros.firstWhere((m) => m.idUsuario == userId).rol;
    } catch (_) {
      return null;
    }
  }

  bool esAdmin(String userId) => getRolUsuario(userId) == 'admin';
  bool esMiembro(String userId) => getRolUsuario(userId) != null;

  AlbergueModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? telefono,
    String? email,
    String? imagen,
    String? ubicacion,
    double? latitud,
    double? longitud,
    bool? verificado,
    String? estado,
    DateTime? createdAt,
    List<UsuarioAlbergueModel>? miembros,
    List<MascotaAlbergueModel>? mascotas,
  }) {
    return AlbergueModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      imagen: imagen ?? this.imagen,
      ubicacion: ubicacion ?? this.ubicacion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      verificado: verificado ?? this.verificado,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      miembros: miembros ?? this.miembros,
      mascotas: mascotas ?? this.mascotas,
    );
  }
}