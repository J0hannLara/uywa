// Datos básicos del dueño — solo lo necesario para mostrar contacto
class DuenoBasicoModel {
  final String id;
  final String nombre;
  final String? telefono;
  final String? fotoPerfil;

  DuenoBasicoModel({
    required this.id,
    required this.nombre,
    this.telefono,
    this.fotoPerfil,
  });

  factory DuenoBasicoModel.fromJson(Map<String, dynamic> json) {
    return DuenoBasicoModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      telefono: json['telefono'] as String?,
      fotoPerfil: json['foto_perfil'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'telefono': telefono,
        'foto_perfil': fotoPerfil,
      };
}

// ============================================

// Datos básicos de la mascota perdida
class MascotaBasicaModel {
  final int id;
  final String? nombre;
  final String tipo;
  final String? raza;
  final String? color;
  final String? imagenPrincipal;
  final DuenoBasicoModel? dueno;

  MascotaBasicaModel({
    required this.id,
    this.nombre,
    required this.tipo,
    this.raza,
    this.color,
    this.imagenPrincipal,
    this.dueno,
  });

  factory MascotaBasicaModel.fromJson(Map<String, dynamic> json) {
    // mascota_usuarios viene como lista filtrada por es_principal
    final relacionesRaw =
        json['mascota_usuarios'] as List<dynamic>? ?? [];

    DuenoBasicoModel? dueno;
    if (relacionesRaw.isNotEmpty) {
      final usuarioRaw = relacionesRaw.first['usuarios'];
      if (usuarioRaw != null) {
        dueno = DuenoBasicoModel.fromJson(
          Map<String, dynamic>.from(usuarioRaw),
        );
      }
    }

    return MascotaBasicaModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String?,
      tipo: json['tipo'] as String,
      raza: json['raza'] as String?,
      color: json['color'] as String?,
      imagenPrincipal: json['imagen_principal'] as String?,
      dueno: dueno,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'raza': raza,
        'color': color,
        'imagen_principal': imagenPrincipal,
        if (dueno != null) 'dueno': dueno!.toJson(),
      };
}

// ============================================

class PerdidaModel {
  final int id;
  final int idMascota;
  final DateTime fechaPerdida;
  final String lugarPerdida;
  final String? descripcionPerdida;
  final double? latitud;
  final double? longitud;
  final int radioBusquedaKm;
  final double? recompensa;
  final String estado;
  final DateTime? fechaEncontrado;
  final String? detallesEncontrado;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Join opcional con mascota + dueño
  final MascotaBasicaModel? mascota;

  PerdidaModel({
    required this.id,
    required this.idMascota,
    required this.fechaPerdida,
    required this.lugarPerdida,
    this.descripcionPerdida,
    this.latitud,
    this.longitud,
    required this.radioBusquedaKm,
    this.recompensa,
    required this.estado,
    this.fechaEncontrado,
    this.detallesEncontrado,
    required this.createdAt,
    required this.updatedAt,
    this.mascota,
  });

  factory PerdidaModel.fromJson(Map<String, dynamic> json) {
    final mascotaRaw = json['mascotas'] as Map<String, dynamic>?;

    return PerdidaModel(
      id: json['id'] as int,
      idMascota: json['id_mascota'] as int,
      fechaPerdida: DateTime.parse(json['fecha_perdida'] as String),
      lugarPerdida: json['lugar_perdida'] as String,
      descripcionPerdida: json['descripcion_perdida'] as String?,
      latitud: json['latitud'] != null
          ? double.tryParse(json['latitud'].toString())
          : null,
      longitud: json['longitud'] != null
          ? double.tryParse(json['longitud'].toString())
          : null,
      radioBusquedaKm: json['radio_busqueda_km'] as int? ?? 5,
      recompensa: json['recompensa'] != null
          ? double.tryParse(json['recompensa'].toString())
          : null,
      estado: json['estado'] as String? ?? 'activa',
      fechaEncontrado: json['fecha_encontrado'] != null
          ? DateTime.parse(json['fecha_encontrado'] as String)
          : null,
      detallesEncontrado: json['detalles_encontrado'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      mascota: mascotaRaw != null
          ? MascotaBasicaModel.fromJson(mascotaRaw)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_mascota': idMascota,
        'fecha_perdida': fechaPerdida.toIso8601String(),
        'lugar_perdida': lugarPerdida,
        'descripcion_perdida': descripcionPerdida,
        'latitud': latitud,
        'longitud': longitud,
        'radio_busqueda_km': radioBusquedaKm,
        'recompensa': recompensa,
        'estado': estado,
        'fecha_encontrado': fechaEncontrado?.toIso8601String(),
        'detalles_encontrado': detallesEncontrado,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        if (mascota != null) 'mascotas': mascota!.toJson(),
      };

  // Para crear — sin id ni timestamps
  Map<String, dynamic> toInsertJson() => {
        'id_mascota': idMascota,
        'fecha_perdida': fechaPerdida.toIso8601String(),
        'lugar_perdida': lugarPerdida,
        if (descripcionPerdida != null)
          'descripcion_perdida': descripcionPerdida,
        if (latitud != null) 'latitud': latitud,
        if (longitud != null) 'longitud': longitud,
        'radio_busqueda_km': radioBusquedaKm,
        if (recompensa != null) 'recompensa': recompensa,
        'estado': estado,
      };

  // Helpers
  bool get estaActiva => estado == 'activa';
  bool get fueEncontrada => estado == 'encontrada';
  bool get estaCerrada => estado == 'cerrada';

  PerdidaModel copyWith({
    int? id,
    int? idMascota,
    DateTime? fechaPerdida,
    String? lugarPerdida,
    String? descripcionPerdida,
    double? latitud,
    double? longitud,
    int? radioBusquedaKm,
    double? recompensa,
    String? estado,
    DateTime? fechaEncontrado,
    String? detallesEncontrado,
    DateTime? createdAt,
    DateTime? updatedAt,
    MascotaBasicaModel? mascota,
  }) {
    return PerdidaModel(
      id: id ?? this.id,
      idMascota: idMascota ?? this.idMascota,
      fechaPerdida: fechaPerdida ?? this.fechaPerdida,
      lugarPerdida: lugarPerdida ?? this.lugarPerdida,
      descripcionPerdida: descripcionPerdida ?? this.descripcionPerdida,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      radioBusquedaKm: radioBusquedaKm ?? this.radioBusquedaKm,
      recompensa: recompensa ?? this.recompensa,
      estado: estado ?? this.estado,
      fechaEncontrado: fechaEncontrado ?? this.fechaEncontrado,
      detallesEncontrado: detallesEncontrado ?? this.detallesEncontrado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mascota: mascota ?? this.mascota,
    );
  }
}