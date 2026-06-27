
class MascotaUsuarioModel {
  final int id;
  final String idUsuario;
  final String rol;
  final String estado;
  final bool esPrincipal;
  final DateTime fechaInicio;
  // 👈 Datos del usuario (viene del join)
  final UsuarioBasicoModel? usuario;

  MascotaUsuarioModel({
    required this.id,
    required this.idUsuario,
    required this.rol,
    required this.estado,
    required this.esPrincipal,
    required this.fechaInicio,
    this.usuario,
  });

  factory MascotaUsuarioModel.fromJson(Map<String, dynamic> json) {
    // 👈 Extraer datos del usuario anidado
    final usuarioData = json['usuarios'] as Map<String, dynamic>?;
    final usuario = usuarioData != null
        ? UsuarioBasicoModel.fromJson(usuarioData)
        : null;

    return MascotaUsuarioModel(
      id: json['id'] as int,
      idUsuario: json['id_usuario'] as String,
      rol: json['rol'] as String,
      estado: json['estado'] as String,
      esPrincipal: json['es_principal'] as bool? ?? false,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      usuario: usuario, // 👈 Asignar datos del usuario
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_usuario': idUsuario,
    'rol': rol,
    'estado': estado,
    'es_principal': esPrincipal,
    'fecha_inicio': fechaInicio.toIso8601String(),
    if (usuario != null) 'usuarios': usuario!.toJson(),
  };
}

// Modelo básico de usuario para mostrar en el detalle de mascota
class UsuarioBasicoModel {
  final String id;
  final String nombre;
  final String email;
  final String? fotoPerfil;
  final String? username;
  final String? telefono;
  final String? ciudad;
  final String? pais;
  final bool verificado;

  UsuarioBasicoModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.fotoPerfil,
    this.username,
    this.telefono,
    this.ciudad,
    this.pais,
    required this.verificado,
  });

  factory UsuarioBasicoModel.fromJson(Map<String, dynamic> json) {
    return UsuarioBasicoModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      fotoPerfil: json['foto_perfil'] as String?,
      username: json['username'] as String?,
      telefono: json['telefono'] as String?,
      ciudad: json['ciudad'] as String?,
      pais: json['pais'] as String?,
      verificado: json['verificado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'email': email,
    'foto_perfil': fotoPerfil,
    'username': username,
    'telefono': telefono,
    'ciudad': ciudad,
    'pais': pais,
    'verificado': verificado,
  };
}
// ============================================

class MascotaModel {
  final int id;
  final String? nombre;
  final String? descripcion;
  final String tipo;
  final String? sexo;
  final String? raza;
  final String? color;
  final int? edad;
  final String? edadTiempo;
  final String? tamano;
  final double? peso;
  final bool esterilizado;
  final bool vacunado;
  final String? imagenPrincipal;
  final String estadoActual;
  final String? microchip;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Relaciones del usuario con esta mascota (viene del join)
  final List<MascotaUsuarioModel> mascotaUsuarios;
  final String mascotaEstado;

  MascotaModel({
    required this.id,
    this.nombre,
    this.descripcion,
    required this.tipo,
    this.sexo,
    this.raza,
    this.color,
    this.edad,
    this.edadTiempo,
    this.tamano,
    this.peso,
    required this.esterilizado,
    required this.vacunado,
    this.imagenPrincipal,
    required this.estadoActual,
    this.microchip,
    required this.createdAt,
    required this.updatedAt,
    this.mascotaUsuarios = const [],
    required this.mascotaEstado,
  });

  factory MascotaModel.fromJson(Map<String, dynamic> json) {
    // Supabase devuelve el join como lista anidada
    final relacionesRaw = json['mascota_usuarios'] as List<dynamic>? ?? [];

    return MascotaModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String?,
      descripcion: json['descripcion'] as String?,
      tipo: json['tipo'] as String,
      sexo: json['sexo'] as String?,
      raza: json['raza'] as String?,
      color: json['color'] as String?,
      edad: json['edad'] as int?,
      edadTiempo: json['edad_tiempo'] as String?,
      tamano: json['tamano'] as String?,
      peso: json['peso'] != null
          ? double.tryParse(json['peso'].toString())
          : null,
      esterilizado: json['esterilizado'] as bool? ?? false,
      vacunado: json['vacunado'] as bool? ?? false,
      imagenPrincipal: json['imagen_principal'] as String?,
      estadoActual: json['estado_actual'] as String? ?? 'pendiente',
      microchip: json['microchip'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      mascotaUsuarios: relacionesRaw
          .map(
            (e) => MascotaUsuarioModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
      mascotaEstado: json['estado_mascota'] as String? ?? 'activo',
    );
  }

  // toJson para cache — incluye relaciones
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'tipo': tipo,
    'sexo': sexo,
    'raza': raza,
    'color': color,
    'edad': edad,
    'edad_tiempo': edadTiempo,
    'tamano': tamano,
    'peso': peso,
    'esterilizado': esterilizado,
    'vacunado': vacunado,
    'imagen_principal': imagenPrincipal,
    'estado_actual': estadoActual,
    'microchip': microchip,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'mascota_usuarios': mascotaUsuarios.map((e) => e.toJson()).toList(),
    'estado_mascota': mascotaEstado,
  };

  // toInsertJson para Supabase — sin id, timestamps ni relaciones
  Map<String, dynamic> toInsertJson() => {
    if (nombre != null) 'nombre': nombre,
    if (descripcion != null) 'descripcion': descripcion,
    'tipo': tipo,
    if (sexo != null) 'sexo': sexo,
    if (raza != null) 'raza': raza,
    if (color != null) 'color': color,
    if (edad != null) 'edad': edad,
    if (edadTiempo != null) 'edad_tiempo': edadTiempo,
    if (tamano != null) 'tamano': tamano,
    if (peso != null) 'peso': peso,
    'esterilizado': esterilizado,
    'vacunado': vacunado,
    if (imagenPrincipal != null) 'imagen_principal': imagenPrincipal,
    'estado_actual': estadoActual,
    if (microchip != null) 'microchip': microchip,
    'estado_mascota': mascotaEstado,
  };

  MascotaModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? tipo,
    String? sexo,
    String? raza,
    String? color,
    int? edad,
    String? edadTiempo,
    String? tamano,
    double? peso,
    bool? esterilizado,
    bool? vacunado,
    String? imagenPrincipal,
    String? estadoActual,
    String? microchip,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MascotaUsuarioModel>? mascotaUsuarios,
    String? mascotaEstado,
  }) {
    return MascotaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      sexo: sexo ?? this.sexo,
      raza: raza ?? this.raza,
      color: color ?? this.color,
      edad: edad ?? this.edad,
      edadTiempo: edadTiempo ?? this.edadTiempo,
      tamano: tamano ?? this.tamano,
      peso: peso ?? this.peso,
      esterilizado: esterilizado ?? this.esterilizado,
      vacunado: vacunado ?? this.vacunado,
      imagenPrincipal: imagenPrincipal ?? this.imagenPrincipal,
      estadoActual: estadoActual ?? this.estadoActual,
      microchip: microchip ?? this.microchip,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mascotaUsuarios: mascotaUsuarios ?? this.mascotaUsuarios,
      mascotaEstado: mascotaEstado ?? this.mascotaEstado,
    );
  }

  bool get isActivo => mascotaEstado == 'activo';
  bool get isPerdido => mascotaEstado == 'perdido';
  bool get isEncontrado => mascotaEstado == 'encontrado';
  bool get isAdoptado => mascotaEstado == 'adoptado';
  bool get isFallecido => mascotaEstado == 'fallecido';


  // Helper para obtener label del estado
  String get estadoLabel {
    switch (mascotaEstado) {
      case 'activo':
        return 'Activo';
      case 'perdido':
        return 'Perdido';
      case 'encontrado':
        return 'Encontrado';
      case 'adoptado':
        return 'Adoptado';
      case 'fallecido':
        return 'Fallecido';
      default:
        return mascotaEstado;
    }
  }

  MascotaUsuarioModel? get dueno {
    try {
      return mascotaUsuarios.firstWhere((r) => r.rol == 'dueno');
    } catch (_) {
      return null;
    }
  }

  // Helper para obtener los datos del dueño directamente
  UsuarioBasicoModel? get duenoInfo {
    return dueno?.usuario;
  }

  // Helper para obtener el nombre del dueño
  String? get duenoNombre {
    return duenoInfo?.nombre ?? duenoInfo?.username;
  }

  // Helper para obtener la foto del dueño
  String? get duenoFoto {
    return duenoInfo?.fotoPerfil;
  }

  // Helper para obtener el rol del usuario actual en esta mascota
  String? getRolUsuario(String userId) {
    try {
      return mascotaUsuarios.firstWhere((r) => r.idUsuario == userId).rol;
    } catch (_) {
      return null;
    }
  }

  // Helper para verificar si el usuario es dueño
  bool esDueno(String userId) => getRolUsuario(userId) == 'dueno';
}
