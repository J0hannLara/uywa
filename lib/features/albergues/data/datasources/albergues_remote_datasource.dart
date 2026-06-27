import 'package:supabase_flutter/supabase_flutter.dart';

// Select base con joins de miembros y mascotas
const _kSelectCompleto = '''
  *,
  usuario_albergue (
    id,
    id_usuario,
    id_albergue,
    rol,
    created_at
  ),
  mascota_albergue (
    id,
    id_mascota,
    id_albergue,
    fecha_ingreso,
    fecha_salida,
    estado,
    created_at
  )
''';

class AlbergueRemoteDatasource {
  final SupabaseClient supabase;

  AlbergueRemoteDatasource(this.supabase);

  // =========================
  // ALBERGUES PÚBLICOS
  // Solo los que están activos y verificados
  // =========================
  Future<List<Map<String, dynamic>>> getAlberguesPublicos({
    int limite = 20,
    int offset = 0,
  }) 
  async {
    final response = await supabase
        .from('albergues')
        .select(_kSelectCompleto)
        .eq('estado', 'activo')
        .eq('verificado', true)
        .order('nombre', ascending: true)
        .range(offset, offset + limite - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  // =========================
  // ALBERGUES DEL USUARIO
  // Los albergues donde el usuario tiene un rol
  // =========================
  Future<List<Map<String, dynamic>>> getMisAlbergues(String userId) async {
    final response = await supabase
        .from('albergues')
        .select(_kSelectCompleto)
        .eq('usuario_albergue.id_usuario', userId)
        .order('nombre', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  // =========================
  // GET BY ID
  // =========================
  Future<Map<String, dynamic>?> getAlbergueById(int id) async {
    return await supabase
        .from('albergues')
        .select(_kSelectCompleto)
        .eq('id', id)
        .maybeSingle();
  }

  // =========================
  // UPDATE ALBERGUE
  // Solo admins — la creación se hace desde el servidor
  // =========================
  Future<void> updateAlbergue({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    await supabase.from('albergues').update(data).eq('id', id);
  }

  // =========================
  // AGREGAR MIEMBRO AL ALBERGUE
  // Solo un admin puede llamar esto desde la app
  // =========================
  Future<void> agregarMiembro({
    required int albergueId,
    required String userId,
    required String rol,
  }) async {
    await supabase.from('usuario_albergue').insert({
      'id_albergue': albergueId,
      'id_usuario': userId,
      'rol': rol,
    });
  }

  // =========================
  // ACTUALIZAR ROL DE MIEMBRO
  // =========================
  Future<void> actualizarRolMiembro({
    required int albergueId,
    required String userId,
    required String nuevoRol,
  }) async {
    await supabase
        .from('usuario_albergue')
        .update({'rol': nuevoRol})
        .eq('id_albergue', albergueId)
        .eq('id_usuario', userId);
  }

  // =========================
  // REMOVER MIEMBRO
  // =========================
  Future<void> removerMiembro({
    required int albergueId,
    required String userId,
  }) async {
    await supabase
        .from('usuario_albergue')
        .delete()
        .eq('id_albergue', albergueId)
        .eq('id_usuario', userId);
  }

  // =========================
  // INGRESAR MASCOTA AL ALBERGUE
  // =========================
  Future<void> ingresarMascota({
    required int mascotaId,
    required int albergueId,
  }) async {
    await supabase.from('mascota_albergue').insert({
      'id_mascota': mascotaId,
      'id_albergue': albergueId,
      'estado': 'activo',
    });
  }

  // =========================
  // ACTUALIZAR ESTADO DE MASCOTA EN ALBERGUE
  // ej: adoptado, transferido, fallecido
  // =========================
  Future<void> actualizarEstadoMascota({
    required int mascotaAlbergueId,
    required String nuevoEstado,
    DateTime? fechaSalida,
  }) async {
    await supabase.from('mascota_albergue').update({
      'estado': nuevoEstado,
      if (fechaSalida != null)
        'fecha_salida': fechaSalida.toIso8601String()
      else if (nuevoEstado != 'activo')
        'fecha_salida': DateTime.now().toIso8601String(),
    }).eq('id', mascotaAlbergueId);
  }

  // =========================
  // MASCOTAS ACTIVAS EN UN ALBERGUE
  // =========================
  Future<List<Map<String, dynamic>>> getMascotasDeAlbergue(
    int albergueId,
  ) async {
    final response = await supabase
        .from('mascota_albergue')
        .select('*, mascotas(*)')
        .eq('id_albergue', albergueId)
        .eq('estado', 'activo')
        .order('fecha_ingreso', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}