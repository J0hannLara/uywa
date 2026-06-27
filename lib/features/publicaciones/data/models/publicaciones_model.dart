class UsuarioPublicacionModel {
  final String id;
  final String nombre;
  final String? username;
  final String? fotoPerfil;
  final String? ciudad;
  final String? pais;

  UsuarioPublicacionModel({
    required this.id,
    required this.nombre,
    this.username,
    this.fotoPerfil,
    this.ciudad,
    this.pais,
  });

  factory UsuarioPublicacionModel.fromJson(Map<String, dynamic> json) {
    return UsuarioPublicacionModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      username: json['username'] as String?,
      fotoPerfil: json['foto_perfil'] as String?,
      ciudad: json['ciudad'] as String?,
      pais: json['pais'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'username': username,
    'foto_perfil': fotoPerfil,
    'ciudad': ciudad,
    'pais': pais,
  };
}

class PublicacionImagenModel {
  final int id;
  final int idPublicacion;
  final String url;
  final int orden;
  final DateTime createdAt;

  PublicacionImagenModel({
    required this.id,
    required this.idPublicacion,
    required this.url,
    required this.orden,
    required this.createdAt,
  });

  factory PublicacionImagenModel.fromJson(Map<String, dynamic> json) {
    return PublicacionImagenModel(
      id: json['id'] as int,
      idPublicacion: json['id_publicacion'] as int,
      url: json['url'] as String,
      orden: json['orden'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_publicacion': idPublicacion,
    'url': url,
    'orden': orden,
    'created_at': createdAt.toIso8601String(),
  };
}

// ============================================

class PublicacionModel {
  final int id;
  final String tipoPublicacion;
  final String titulo;
  final String? descripcion;
  final String estado;
  final String? ubicacionTexto;
  final double? latitud;
  final double? longitud;
  final int compartidos;
  final int visualizaciones;
  final bool activo;
  final String idUsuario;
  final int? idMascota;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? idReferencia;
  final UsuarioPublicacionModel? usuario;
  // Imágenes relacionadas — se cargan con el join
  final List<PublicacionImagenModel> imagenes;

  PublicacionModel({
    required this.id,
    required this.tipoPublicacion,
    required this.titulo,
    this.descripcion,
    required this.estado,
    this.ubicacionTexto,
    this.latitud,
    this.longitud,
    required this.compartidos,
    required this.visualizaciones,
    required this.activo,
    required this.idUsuario,
    this.idMascota,
    required this.createdAt,
    required this.updatedAt,
    this.imagenes = const [],
    this.idReferencia,
    this.usuario,
  });

  factory PublicacionModel.fromJson(Map<String, dynamic> json) {
    // Supabase devuelve el join como lista dentro del mismo mapa
    final imagenesRaw = json['publicacion_imagenes'] as List<dynamic>? ?? [];

    final usuarioData = json['usuarios'] as Map<String, dynamic>?;
    final usuario = usuarioData != null
        ? UsuarioPublicacionModel.fromJson(usuarioData)
        : null;

    return PublicacionModel(
      id: json['id'] as int,
      tipoPublicacion: json['tipo_publicacion'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      estado: json['estado'] as String? ?? 'activa',
      ubicacionTexto: json['ubicacion_texto'] as String?,
      latitud: json['latitud'] != null
          ? double.tryParse(json['latitud'].toString())
          : null,
      longitud: json['longitud'] != null
          ? double.tryParse(json['longitud'].toString())
          : null,
      compartidos: json['compartidos'] as int? ?? 0,
      visualizaciones: json['visualizaciones'] as int? ?? 0,
      activo: json['activo'] as bool? ?? true,
      idReferencia: json['id_referencia'] as int?,
      idUsuario: json['id_usuario'] as String,
      idMascota: json['id_mascota'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      imagenes:
          imagenesRaw
              .map(
                (e) => PublicacionImagenModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
            ..sort((a, b) => a.orden.compareTo(b.orden)),
      usuario: usuario,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tipo_publicacion': tipoPublicacion,
    'titulo': titulo,
    'descripcion': descripcion,
    'estado': estado,
    'ubicacion_texto': ubicacionTexto,
    'latitud': latitud,
    'longitud': longitud,
    'compartidos': compartidos,
    'visualizaciones': visualizaciones,
    'activo': activo,
    'id_referencia': idReferencia,
    'id_usuario': idUsuario,
    'id_mascota': idMascota,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'publicacion_imagenes': imagenes.map((e) => e.toJson()).toList(),
    if (usuario != null) 'usuarios': usuario!.toJson(),
  };

  // Solo los campos que se insertan en Supabase — sin id ni timestamps
  Map<String, dynamic> toInsertJson() => {
    'tipo_publicacion': tipoPublicacion,
    'titulo': titulo,
    if (descripcion != null) 'descripcion': descripcion,
    'estado': estado,
    if (ubicacionTexto != null) 'ubicacion_texto': ubicacionTexto,
    if (latitud != null) 'latitud': latitud,
    if (longitud != null) 'longitud': longitud,
    'id_usuario': idUsuario,
    if (idMascota != null) 'id_mascota': idMascota,
  };

  PublicacionModel copyWith({
    int? id,
    String? tipoPublicacion,
    String? titulo,
    String? descripcion,
    String? estado,
    String? ubicacionTexto,
    double? latitud,
    double? longitud,
    int? compartidos,
    int? visualizaciones,
    bool? activo,
    String? idUsuario,
    int? idMascota,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PublicacionImagenModel>? imagenes,
  }) {
    return PublicacionModel(
      id: id ?? this.id,
      tipoPublicacion: tipoPublicacion ?? this.tipoPublicacion,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      ubicacionTexto: ubicacionTexto ?? this.ubicacionTexto,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      compartidos: compartidos ?? this.compartidos,
      visualizaciones: visualizaciones ?? this.visualizaciones,
      activo: activo ?? this.activo,
      idUsuario: idUsuario ?? this.idUsuario,
      idMascota: idMascota ?? this.idMascota,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imagenes: imagenes ?? this.imagenes,
    );
  }
}
