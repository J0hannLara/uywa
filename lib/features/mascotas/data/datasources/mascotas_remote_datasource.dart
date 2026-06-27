import 'package:supabase_flutter/supabase_flutter.dart';

// Join completo: datos de mascota + relación del usuario
const _kSelectConUsuario = '''
  *,
  mascota_usuarios!inner (
    id,
    id_usuario,
    rol,
    estado,
    es_principal,
    fecha_inicio,
    usuarios!inner (
      id,
      nombre,
      email,
      foto_perfil,
      username,
      telefono,
      ciudad,
      pais,
      verificado
    )
  )
''';
class MascotaRemoteDatasource {
  final SupabaseClient supabase;

  MascotaRemoteDatasource(this.supabase);

  // =========================
  // GET MASCOTAS DEL USUARIO
  // Filtra por id_usuario en mascota_usuarios
  // Solo trae relaciones activas
  // =========================
  Future<List<Map<String, dynamic>>> getMascotas(String userId) async {
    final response = await supabase
        .from('mascotas')
        .select(_kSelectConUsuario)
        .eq('mascota_usuarios.id_usuario', userId)
        .eq('mascota_usuarios.estado', 'activo')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // =========================
  // GET BY ID
  // Trae la mascota con todas sus relaciones de usuario
  // =========================
  Future<Map<String, dynamic>?> getMascotaById(int id) async {
    return await supabase
        .from('mascotas')
        .select(_kSelectConUsuario)
        .eq('id', id)
        .maybeSingle();
  }

  // =========================
  // CREATE MASCOTA
  // Inserta en mascotas y devuelve el id generado
  // =========================
  Future<int> createMascota(Map<String, dynamic> data) async {
    final response = await supabase
        .from('mascotas')
        .insert(data)
        .select('id')
        .single();

    return response['id'] as int;
  }

  // =========================
  // CREATE RELACIÓN USUARIO
  // Se llama justo después de createMascota
  // Estado en 'activo' desde el inicio porque el dueño
  // es quien registra su propia mascota
  // =========================
  Future<void> createMascotaUsuario({
    required int mascotaId,
    required String userId,
    String rol = 'dueno',
  }) async {
    await supabase.from('mascota_usuarios').insert({
      'id_mascota': mascotaId,
      'id_usuario': userId,
      'rol': rol,
      'estado': 'activo',
      'es_principal': true,
    });
  }

  // =========================
  // UPDATE MASCOTA
  // Solo actualiza la tabla mascotas
  // =========================
  Future<void> updateMascota({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    await supabase.from('mascotas').update(data).eq('id', id);
  }

  // =========================
  // DELETE MASCOTA
  // El CASCADE en BD elimina mascota_usuarios automáticamente
  // =========================
  Future<void> deleteMascota(int id) async {
    await supabase.from('mascotas').delete().eq('id', id);
  }
}
