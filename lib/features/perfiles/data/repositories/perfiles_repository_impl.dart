import '../../domain/repositories/profile_repository.dart';

import '../datasources/perfiles_remote_datasource.dart';

import 'package:mypets/features/auth/data/models/usuario_model.dart';

class ProfileRepositoryImpl
    implements ProfileRepository {

  final ProfileRemoteDatasource
      datasource;

  ProfileRepositoryImpl(
    this.datasource,
  );

  @override
  Future<UsuarioModel?> getCurrentUser(
    String userId,
  ) async {

    final response =
        await datasource.getCurrentUser(
      userId,
    );

    return UsuarioModel.fromJson(
      response,
    );
  }

  @override
  Future<void> updateBasicInfo({

    required String userId,

    required String nombre,

    required String telefono,

    required String ciudad,

    required String pais,

  }) async {

    await datasource.updateBasicInfo(

      userId: userId,

      nombre: nombre,

      telefono: telefono,

      ciudad: ciudad,

      pais: pais,
    );
  }

  @override
  Future<void> updateProfileInfo({

    required String userId,

    required String username,

    required String descripcion,

    String? fotoPerfil,

  }) async {

    await datasource.updateProfileInfo(

      userId: userId,

      username: username,

      descripcion: descripcion,

      fotoPerfil: fotoPerfil,
    );
  }

  @override
  Future<bool> usernameExists({

    required String username,

    required String currentUserId,

  }) async {

    return await datasource
        .usernameExists(

      username: username,

      currentUserId:
          currentUserId,
    );
  }
}