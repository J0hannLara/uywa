import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDatasource {

  final SupabaseClient supabase;

  ProfileRemoteDatasource(
    this.supabase,
  );

  Future<Map<String, dynamic>>
      getCurrentUser(
    String userId,
  ) async {

    return await supabase
        .from('usuarios')
        .select()
        .eq('id', userId)
        .single();
  }

  Future<void> updateBasicInfo({

    required String userId,

    required String nombre,

    required String telefono,

    required String ciudad,

    required String pais,

  }) async {

    await supabase
        .from('usuarios')
        .update({

      'nombre': nombre,

      'telefono': telefono,

      'ciudad': ciudad,

      'pais': pais,

      'onboarding_step': 2,

    })
        .eq('id', userId);
  }

  Future<void> updateProfileInfo({

    required String userId,

    required String username,

    required String descripcion,

    String? fotoPerfil,

  }) async {

    await supabase
        .from('usuarios')
        .update({

      'username': username,

      'descripcion': descripcion,

      'foto_perfil': fotoPerfil,

      'perfil_completo': true,

      'onboarding_step': 3,

    })
        .eq('id', userId);
  }

  Future<bool> usernameExists({

    required String username,

    required String currentUserId,

  }) async {

    final response = await supabase
        .from('usuarios')
        .select('id')
        .eq('username', username)
        .neq('id', currentUserId)
        .maybeSingle();

    return response != null;
  }
}