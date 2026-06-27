import 'package:supabase_flutter/supabase_flutter.dart';

class InsigniaRemoteDatasource {
  final SupabaseClient supabase;

  InsigniaRemoteDatasource(this.supabase);

  // =========================
  // GET TODAS LAS INSIGNIAS
  // Vista pública — cualquier usuario puede verlas
  // =========================
  Future<List<Map<String, dynamic>>> getInsignias({
    String? tipoFiltro,
  }) async {
    final query = tipoFiltro != null
        ? supabase
            .from('insignias')
            .select()
            .eq('tipo', tipoFiltro)
            .order('nombre', ascending: true)
        : supabase
            .from('insignias')
            .select()
            .order('nombre', ascending: true);

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // =========================
  // GET INSIGNIAS DE UN USUARIO
  // Hace join con usuario_insignia para traer
  // la fecha en que las obtuvo
  // =========================
  Future<List<Map<String, dynamic>>> getInsigniasDeUsuario(
    String userId,
  ) async {
    final response = await supabase
        .from('insignias')
        .select('*, usuario_insignia!inner(id, id_usuario, fecha_obtenida)')
        .eq('usuario_insignia.id_usuario', userId)
        .order('nombre', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  // =========================
  // GET BY ID
  // =========================
  Future<Map<String, dynamic>?> getInsigniaById(int id) async {
    return await supabase
        .from('insignias')
        .select()
        .eq('id', id)
        .maybeSingle();
  }

  // =========================
  // GET USUARIOS QUE TIENEN UNA INSIGNIA
  // Vista para el panel admin
  // =========================
  Future<List<Map<String, dynamic>>> getUsuariosDeInsignia(
    int insigniaId,
  ) async {
    final response = await supabase
        .from('usuario_insignia')
        .select('*, usuarios(id, nombre, email, foto_perfil)')
        .eq('id_insignia', insigniaId)
        .order('fecha_obtenida', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // =========================
  // CREATE INSIGNIA — solo admin
  // =========================
  Future<int> createInsignia(Map<String, dynamic> data) async {
    final response = await supabase
        .from('insignias')
        .insert(data)
        .select('id')
        .single();

    return response['id'] as int;
  }

  // =========================
  // UPDATE INSIGNIA — solo admin
  // =========================
  Future<void> updateInsignia({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    await supabase.from('insignias').update(data).eq('id', id);
  }

  // =========================
  // DELETE INSIGNIA — solo admin
  // CASCADE elimina usuario_insignia automáticamente
  // =========================
  Future<void> deleteInsignia(int id) async {
    await supabase.from('insignias').delete().eq('id', id);
  }

  // =========================
  // ASIGNAR INSIGNIA A USUARIO — solo admin
  // =========================
  Future<void> asignarInsignia({
    required int insigniaId,
    required String userId,
  }) async {
    await supabase.from('usuario_insignia').insert({
      'id_insignia': insigniaId,
      'id_usuario': userId,
    });
  }

  // =========================
  // REVOCAR INSIGNIA DE USUARIO — solo admin
  // =========================
  Future<void> revocarInsignia({
    required int insigniaId,
    required String userId,
  }) async {
    await supabase
        .from('usuario_insignia')
        .delete()
        .eq('id_insignia', insigniaId)
        .eq('id_usuario', userId);
  }

  // =========================
  // VERIFICAR SI USUARIO TIENE INSIGNIA
  // Útil antes de asignar para evitar duplicados
  // =========================
  Future<bool> usuarioTieneInsignia({
    required int insigniaId,
    required String userId,
  }) async {
    final response = await supabase
        .from('usuario_insignia')
        .select('id')
        .eq('id_insignia', insigniaId)
        .eq('id_usuario', userId)
        .maybeSingle();

    return response != null;
  }
}