class UsuarioModel {

  final String id;
  final String email;

  final String? nombre;
  final String? username;
  final String? telefono;
  final String? fotoPerfil;
  final String? descripcion;
  final String? ciudad;
  final String? pais;

  final int onboardingStep;

  final bool perfilCompleto;
  final bool verificado;

  final DateTime? createdAt;

  UsuarioModel({
    required this.id,
    required this.email,

    this.nombre,
    this.username,
    this.telefono,
    this.fotoPerfil,
    this.descripcion,
    this.ciudad,
    this.pais,

    required this.onboardingStep,
    required this.perfilCompleto,
    required this.verificado,

    this.createdAt,
  });

  factory UsuarioModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return UsuarioModel(

      id: json['id'],

      email: json['email'],

      nombre: json['nombre'],

      username: json['username'],

      telefono: json['telefono'],

      fotoPerfil: json['foto_perfil'],

      descripcion: json['descripcion'],

      ciudad: json['ciudad'],

      pais: json['pais'],

      onboardingStep:
          json['onboarding_step'] ?? 1,

      perfilCompleto:
          json['perfil_completo'] ?? false,

      verificado:
          json['verificado'] ?? false,

      createdAt:
          json['created_at'] != null
              ? DateTime.parse(
                  json['created_at'],
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'email': email,

      'nombre': nombre,

      'username': username,

      'telefono': telefono,

      'foto_perfil': fotoPerfil,

      'descripcion': descripcion,

      'ciudad': ciudad,

      'pais': pais,

      'onboarding_step': onboardingStep,

      'perfil_completo': perfilCompleto,

      'verificado': verificado,

      'created_at':
          createdAt?.toIso8601String(),
    };
  }
}