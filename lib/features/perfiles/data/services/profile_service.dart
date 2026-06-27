/* import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/cache/cache_service.dart';
import '../../../../core/services/session_controller.dart';

import '../../../auth/data/models/usuario_model.dart';

class ProfileService extends GetxController {

  final supabase =
      Supabase.instance.client;

  final session =
      Get.find<SessionController>();

  Future<UsuarioModel?> cargarUsuario() async {

    try {

      session.isLoading.value = true;

      final authUser =
          supabase.auth.currentUser;

      if (authUser == null) {
        return null;
      }

      final response = await supabase
          .from('usuarios')
          .select()
          .eq('id', authUser.id)
          .single();

      final usuario =
          UsuarioModel.fromJson(response);

      session.currentUser.value =
          usuario;

      await CacheService.userBox.put(
        'current_user',
        usuario.toJson(),
      );

      return usuario;

    } catch (e) {

      print(
        'ERROR cargarUsuario: $e',
      );

      return null;

    } finally {

      session.isLoading.value = false;
    }
  }

  UsuarioModel? getCachedUser() {

    final data =
        CacheService.userBox.get(
          'current_user',
        );

    if (data == null) {
      return null;
    }

    return UsuarioModel.fromJson(data);
  }

  Future<void> updateBasicInfo({

    required String nombre,
    required String telefono,
    required String ciudad,
    required String pais,

  }) async {

    try {

      final authUser =
          supabase.auth.currentUser;

      if (authUser == null) return;

      await supabase
          .from('usuarios')
          .update({

        'nombre': nombre,

        'telefono': telefono,

        'ciudad': ciudad,

        'pais': pais,

        'onboarding_step': 2,

      })
          .eq('id', authUser.id);

      await cargarUsuario();

    } catch (e) {

      print(
        'ERROR updateBasicInfo: $e',
      );
    }
  }

  Future<void> updateProfileInfo({

    required String username,
    required String descripcion,

  }) async {

    try {

      final authUser =
          supabase.auth.currentUser;

      if (authUser == null) return;

      await supabase
          .from('usuarios')
          .update({

        'username': username,

        'descripcion': descripcion,

        'perfil_completo': true,

        'onboarding_step': 3,

      })
          .eq('id', authUser.id);

      await cargarUsuario();

    } catch (e) {

      print(
        'ERROR updateProfileInfo: $e',
      );
    }
  }

  Future<bool> usernameExists(
    String username,
  ) async {

    final response = await supabase
        .from('usuarios')
        .select('id')
        .eq('username', username)
        .maybeSingle();

    return response != null;
  }
} */