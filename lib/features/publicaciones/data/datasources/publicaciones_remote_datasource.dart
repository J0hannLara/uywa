import 'package:supabase_flutter/supabase_flutter.dart';

const _kSelectConImagenes = '''
  *,
  publicacion_imagenes (
    id,
    id_publicacion,
    url,
    orden,
    created_at
  ),
  usuarios!inner (
    id,
    nombre,
    username,
    foto_perfil,
    ciudad,
    pais
  )
''';

class PublicacionRemoteDatasource {
  final SupabaseClient supabase;

  PublicacionRemoteDatasource(this.supabase);

  // =========================
  // FEED GLOBAL
  // El filtro por tipo se aplica ANTES del order/range
  // para evitar el error de PostgrestTransformBuilder
  // =========================
  Future<List<Map<String, dynamic>>> getFeedGlobal({
    int limite = 20,
    int offset = 0,
    String? tipofiltro,
  }) async {
    // Construir el filtro base separado del transform
    final query = tipofiltro != null
        ? supabase
            .from('publicaciones')
            .select(_kSelectConImagenes)
            .eq('activo', true)
            .eq('tipo_publicacion', tipofiltro)
            .order('created_at', ascending: false)
            .range(offset, offset + limite - 1)
        : supabase
            .from('publicaciones')
            .select(_kSelectConImagenes)
            .eq('activo', true)
            .order('created_at', ascending: false)
            .range(offset, offset + limite - 1);

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // =========================
  // MIS PUBLICACIONES
  // =========================
  Future<List<Map<String, dynamic>>> getMisPublicaciones(
    String userId, {
    int limite = 20,
    int offset = 0,
  }) async {
    final response = await supabase
        .from('publicaciones')
        .select(_kSelectConImagenes)
        .eq('id_usuario', userId)
        .eq('activo', true)
        .order('created_at', ascending: false)
        .range(offset, offset + limite - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  // =========================
  // GET BY ID
  // =========================
  Future<Map<String, dynamic>?> getPublicacionById(int id) async {
    return await supabase
        .from('publicaciones')
        .select(_kSelectConImagenes)
        .eq('id', id)
        .maybeSingle();
  }

  // =========================
  // CREATE — devuelve el id generado
  // =========================
  Future<int> createPublicacion(Map<String, dynamic> data) async {
    final response = await supabase
        .from('publicaciones')
        .insert(data)
        .select('id')
        .single();

    return response['id'] as int;
  }

  // =========================
  // INSERT IMÁGENES
  // =========================
  Future<void> insertImagenes(int publicacionId, List<String> urls) async {
    final data = urls
        .asMap()
        .entries
        .map((e) => {
              'id_publicacion': publicacionId,
              'url': e.value,
              'orden': e.key,
            })
        .toList();

    await supabase.from('publicacion_imagenes').insert(data);
  }

  // =========================
  // UPDATE
  // =========================
  Future<void> updatePublicacion({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    await supabase.from('publicaciones').update(data).eq('id', id);
  }

  // =========================
  // REEMPLAZAR IMÁGENES
  // =========================
  Future<void> reemplazarImagenes(
      int publicacionId, List<String> nuevasUrls) async {
    await supabase
        .from('publicacion_imagenes')
        .delete()
        .eq('id_publicacion', publicacionId);

    if (nuevasUrls.isNotEmpty) {
      await insertImagenes(publicacionId, nuevasUrls);
    }
  }

  // =========================
  // SOFT DELETE
  // =========================
  Future<void> deletePublicacion(int id) async {
    await supabase
        .from('publicaciones')
        .update({'activo': false}).eq('id', id);
  }

  // =========================
  // VISUALIZACIONES
  // =========================
  Future<void> incrementarVisualizacion(int publicacionId) async {
    await supabase.rpc(
      'incrementar_visualizacion',
      params: {'publicacion_id': publicacionId},
    );
  }
}