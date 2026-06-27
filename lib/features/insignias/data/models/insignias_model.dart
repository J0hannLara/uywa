class UsuarioInsigniaModel {
  final int id;
  final String idUsuario;
  final int idInsignia;
  final DateTime fechaObtenida;

  UsuarioInsigniaModel({
    required this.id,
    required this.idUsuario,
    required this.idInsignia,
    required this.fechaObtenida,
  });

  factory UsuarioInsigniaModel.fromJson(Map<String, dynamic> json) {
    return UsuarioInsigniaModel(
      id: json['id'] as int,
      idUsuario: json['id_usuario'] as String,
      idInsignia: json['id_insignia'] as int,
      fechaObtenida: DateTime.parse(json['fecha_obtenida'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_usuario': idUsuario,
        'id_insignia': idInsignia,
        'fecha_obtenida': fechaObtenida.toIso8601String(),
      };
}

// ============================================

class InsigniaModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? imagen;
  final String? tipo;
  final DateTime createdAt;
  // Populated cuando se hace join con usuario_insignia
  final DateTime? fechaObtenida;

  InsigniaModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.imagen,
    this.tipo,
    required this.createdAt,
    this.fechaObtenida,
  });

  factory InsigniaModel.fromJson(Map<String, dynamic> json) {
    // fechaObtenida viene del join con usuario_insignia
    final usuarioInsigniaRaw =
        json['usuario_insignia'] as List<dynamic>?;
    DateTime? fechaObtenida;
    if (usuarioInsigniaRaw != null && usuarioInsigniaRaw.isNotEmpty) {
      fechaObtenida = DateTime.parse(
        usuarioInsigniaRaw.first['fecha_obtenida'] as String,
      );
    }

    return InsigniaModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      imagen: json['imagen'] as String?,
      tipo: json['tipo'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      fechaObtenida: fechaObtenida,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'imagen': imagen,
        'tipo': tipo,
        'created_at': createdAt.toIso8601String(),
        if (fechaObtenida != null)
          'fecha_obtenida': fechaObtenida!.toIso8601String(),
      };

  // toInsertJson para crear en Supabase — sin id ni timestamps
  Map<String, dynamic> toInsertJson() => {
        'nombre': nombre,
        if (descripcion != null) 'descripcion': descripcion,
        if (imagen != null) 'imagen': imagen,
        if (tipo != null) 'tipo': tipo,
      };

  InsigniaModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? imagen,
    String? tipo,
    DateTime? createdAt,
    DateTime? fechaObtenida,
  }) {
    return InsigniaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      imagen: imagen ?? this.imagen,
      tipo: tipo ?? this.tipo,
      createdAt: createdAt ?? this.createdAt,
      fechaObtenida: fechaObtenida ?? this.fechaObtenida,
    );
  }
}