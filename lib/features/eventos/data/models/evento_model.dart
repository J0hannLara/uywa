class UsuarioEventoModel {
  final int id;
  final String idUsuario;
  final int idEvento;
  final bool reclamado;
  final DateTime? fechaReclamo;
  final DateTime createdAt;

  UsuarioEventoModel({
    required this.id,
    required this.idUsuario,
    required this.idEvento,
    required this.reclamado,
    this.fechaReclamo,
    required this.createdAt,
  });

  factory UsuarioEventoModel.fromJson(Map<String, dynamic> json) {
    return UsuarioEventoModel(
      id: json['id'] as int,
      idUsuario: json['id_usuario'] as String,
      idEvento: json['id_evento'] as int,
      reclamado: json['reclamado'] as bool? ?? false,
      fechaReclamo: json['fecha_reclamo'] != null
          ? DateTime.parse(json['fecha_reclamo'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_usuario': idUsuario,
        'id_evento': idEvento,
        'reclamado': reclamado,
        'fecha_reclamo': fechaReclamo?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  UsuarioEventoModel copyWith({
    bool? reclamado,
    DateTime? fechaReclamo,
  }) {
    return UsuarioEventoModel(
      id: id,
      idUsuario: idUsuario,
      idEvento: idEvento,
      reclamado: reclamado ?? this.reclamado,
      fechaReclamo: fechaReclamo ?? this.fechaReclamo,
      createdAt: createdAt,
    );
  }
}

// ============================================

class EventoModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String tipo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool activo;
  final int? idInsignia;
  final int? limiteReclamos;
  final String? imagenUrl;
  final DateTime createdAt;
  // Join opcional — participación del usuario actual
  final UsuarioEventoModel? participacion;
  // Total de participantes — viene de COUNT en el query
  final int totalParticipantes;

  EventoModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tipo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.activo,
    this.idInsignia,
    this.limiteReclamos,
    this.imagenUrl,
    required this.createdAt,
    this.participacion,
    this.totalParticipantes = 0,
  });

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    // Join con usuario_eventos — lista de participaciones
    final participacionesRaw =
        json['usuario_eventos'] as List<dynamic>? ?? [];
    UsuarioEventoModel? participacion;
    if (participacionesRaw.isNotEmpty) {
      participacion = UsuarioEventoModel.fromJson(
        Map<String, dynamic>.from(participacionesRaw.first),
      );
    }

    return EventoModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      tipo: json['tipo'] as String,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: DateTime.parse(json['fecha_fin'] as String),
      activo: json['activo'] as bool? ?? true,
      idInsignia: json['id_insignia'] as int?,
      limiteReclamos: json['limite_reclamos'] as int?,
      imagenUrl: json['imagen_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      participacion: participacion,
      totalParticipantes: json['total_participantes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'tipo': tipo,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        'activo': activo,
        'id_insignia': idInsignia,
        'limite_reclamos': limiteReclamos,
        'imagen_url': imagenUrl,
        'created_at': createdAt.toIso8601String(),
        'total_participantes': totalParticipantes,
        if (participacion != null)
          'usuario_eventos': [participacion!.toJson()],
      };

  Map<String, dynamic> toInsertJson() => {
        'nombre': nombre,
        'tipo': tipo,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        if (descripcion != null) 'descripcion': descripcion,
        if (idInsignia != null) 'id_insignia': idInsignia,
        if (limiteReclamos != null) 'limite_reclamos': limiteReclamos,
        if (imagenUrl != null) 'imagen_url': imagenUrl,
        'activo': activo,
      };

  // Helpers
  bool get estaActivo => activo && DateTime.now().isBefore(fechaFin);
  bool get haIniciado => DateTime.now().isAfter(fechaInicio);
  bool get estaVigente => estaActivo && haIniciado;
  bool get usuarioParticipa => participacion != null;
  bool get usuarioReclamo => participacion?.reclamado ?? false;
  bool get limiteAlcanzado =>
      limiteReclamos != null && totalParticipantes >= limiteReclamos!;

  EventoModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? tipo,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? activo,
    int? idInsignia,
    int? limiteReclamos,
    String? imagenUrl,
    DateTime? createdAt,
    UsuarioEventoModel? participacion,
    int? totalParticipantes,
  }) {
    return EventoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      activo: activo ?? this.activo,
      idInsignia: idInsignia ?? this.idInsignia,
      limiteReclamos: limiteReclamos ?? this.limiteReclamos,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      createdAt: createdAt ?? this.createdAt,
      participacion: participacion ?? this.participacion,
      totalParticipantes: totalParticipantes ?? this.totalParticipantes,
    );
  }
}