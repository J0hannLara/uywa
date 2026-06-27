import 'package:supabase_flutter/supabase_flutter.dart';

// Join completo: perdida → mascota → dueño principal
// mascota_usuarios filtrado por es_principal=true trae al dueño
const _kSelectConMascotaYDueno = '''
  *,
  mascotas (
    id,
    nombre,
    tipo,
    raza,
    color,
    imagen_principal,
    mascota_usuarios!inner (
      es_principal,
      usuarios (
        id,
        nombre,
        telefono,
        foto_perfil
      )
    )
  )
''';

class PerdidaRemoteDatasource {
  final SupabaseClient supabase;

  PerdidaRemoteDatasource(this.supabase);

  // =========================
  // GET TODAS LAS PERDIDAS
  // Con mascota y dueño incluidos
  // =========================
  Future<List<Map<String, dynamic>>> getPerdidas({
    String? estadoFiltro,
    int limite = 20,
    int offset = 0,
  }) async {
    final query = estadoFiltro != null
        ? supabase
            .from('perdidas')
            .select(_kSelectConMascotaYDueno)
            .eq('estado', estadoFiltro)
            .eq('mascotas.mascota_usuarios.es_principal', true)
            .order('fecha_perdida', ascending: false)
            .range(offset, offset + limite - 1)
        : supabase
            .from('perdidas')
            .select(_kSelectConMascotaYDueno)
            .eq('mascotas.mascota_usuarios.es_principal', true)
            .order('fecha_perdida', ascending: false)
            .range(offset, offset + limite - 1);

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // =========================
  // GET PERDIDAS DE UNA MASCOTA ESPECÍFICA
  // =========================
  Future<List<Map<String, dynamic>>> getPerdidasPorMascota(
    int mascotaId,
  ) async {
    final response = await supabase
        .from('perdidas')
        .select(_kSelectConMascotaYDueno)
        .eq('id_mascota', mascotaId)
        .eq('mascotas.mascota_usuarios.es_principal', true)
        .order('fecha_perdida', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // =========================
  // GET BY ID
  // =========================
  Future<Map<String, dynamic>?> getPerdidaById(int id) async {
    return await supabase
        .from('perdidas')
        .select(_kSelectConMascotaYDueno)
        .eq('id', id)
        .eq('mascotas.mascota_usuarios.es_principal', true)
        .maybeSingle();
  }

  // =========================
  // CREATE
  // =========================
  Future<int> createPerdida(Map<String, dynamic> data) async {
    final response = await supabase
        .from('perdidas')
        .insert(data)
        .select('id')
        .single();

    return response['id'] as int;
  }

  // =========================
  // UPDATE
  // =========================
  Future<void> updatePerdida({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    await supabase.from('perdidas').update(data).eq('id', id);
  }

  // =========================
  // MARCAR COMO ENCONTRADA
  // Setea estado, fecha y detalles en un solo update
  // =========================
  Future<void> marcarComoEncontrada({
    required int id,
    String? detalles,
  }) async {
    await supabase.from('perdidas').update({
      'estado': 'encontrada',
      'fecha_encontrado': DateTime.now().toIso8601String(),
      if (detalles != null) 'detalles_encontrado': detalles,
    }).eq('id', id);
  }

  // =========================
  // DELETE
  // =========================
  Future<void> deletePerdida(int id) async {
    await supabase.from('perdidas').delete().eq('id', id);
  }
}