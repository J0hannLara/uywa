import 'package:mypets/features/auth/data/models/usuario_model.dart';

abstract class ProfileRepository {

  Future<UsuarioModel?> getCurrentUser(
    String userId,
  );

  Future<void> updateBasicInfo({

    required String userId,

    required String nombre,

    required String telefono,

    required String ciudad,

    required String pais,
  });

  Future<void> updateProfileInfo({

    required String userId,

    required String username,

    required String descripcion,

    String? fotoPerfil,
  });

  Future<bool> usernameExists({

    required String username,

    required String currentUserId,
  });
}