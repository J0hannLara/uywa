import 'package:supabase_flutter/supabase_flutter.dart';

class EventoRemoteDatasource {
  final SupabaseClient supabase;

  EventoRemoteDatasource(this.supabase);

  // Select con join de participación del usuario actual
  String _selectConParticipacion(String userId) => '''
    *,
    usuario_eventos!left (
      id,
      id_usuario,
      id_evento,
      reclamado,
      fecha_reclamo,
      created_at
    )
  ''';

  // =========================
  // GET EVENTOS ACTIVOS — público
  // =========================
  Future<List<Map<String, dynamic>>> getEventosActivos({
    required String userId,
    int limite = 20,
    int offset = 0,
  }) async {
    final response = await supabase
        .from('eventos')
        .select(_selectConParticipacion(userId))
        .eq('activo', true)
        .eq('usuario_eventos.id_usuario', userId)
        .gte('fecha_fin', DateTime.now().toIso8601String())
        .order('fecha_inicio', ascending: true)
        .range(offset, offset + limite - 1);

    // Enriquecer con total de participantes
    return _enriquecerConTotal(List<Map<String, dynamic>>.from(response));
  }

  // =========================
  // GET TODOS LOS EVENTOS — panel admin
  // Incluye inactivos y vencidos
  // =========================
  Future<List<Map<String, dynamic>>> getEventosAdmin({
    int limite = 20,
    int offset = 0,
  }) async {
    try {
      print('📡 [RemoteDatasource] getEventosAdmin - Iniciando');
      print('📡 [RemoteDatasource] Parámetros: limite=$limite, offset=$offset');
      final query = await supabase
          .from('eventos')
          .select('*, usuario_eventos(id)')
          .order('fecha_inicio', ascending: false)
          .range(offset, offset + limite - 1);
      print('📡 [RemoteDatasource] Query construida');

      final response = await query;

      print('📡 [RemoteDatasource] Response recibida');
      print('📡 [RemoteDatasource] Cantidad de eventos: ${response.length}');

      if (response.isNotEmpty) {
        print(
          '📡 [RemoteDatasource] Primer evento: ${response.first['nombre']}',
        );
        print('📡 [RemoteDatasource] Response completa: $response');
      } else {
        print('📡 [RemoteDatasource] Response vacía');
      }

      return _enriquecerConTotal(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      print('❌ [RemoteDatasource] Error en getEventosAdmin: $e');
      print('❌ [RemoteDatasource] Stacktrace: ${StackTrace.current}');
      rethrow;
    }
  }

  // =========================
  // GET MIS EVENTOS — eventos en los que participa el usuario
  // =========================
  Future<List<Map<String, dynamic>>> getMisEventos(String userId) async {
    final response = await supabase
        .from('eventos')
        .select(_selectConParticipacion(userId))
        .eq('usuario_eventos.id_usuario', userId)
        .order('fecha_inicio', ascending: false);

    return _enriquecerConTotal(List<Map<String, dynamic>>.from(response));
  }

  // =========================
  // GET BY ID
  // =========================
  Future<Map<String, dynamic>?> getEventoById({
    required int id,
    required String userId,
  }) async {
    final response = await supabase
        .from('eventos')
        .select(_selectConParticipacion(userId))
        .eq('id', id)
        .eq('usuario_eventos.id_usuario', userId)
        .maybeSingle();

    if (response == null) return null;

    final total = await _contarParticipantes(id);
    return {...response, 'total_participantes': total};
  }

  // =========================
  // CREATE EVENTO — solo admin
  // =========================
  Future<int> createEvento(Map<String, dynamic> data) async {
    final response = await supabase
        .from('eventos')
        .insert(data)
        .select('id')
        .single();

    return response['id'] as int;
  }

  // =========================
  // UPDATE EVENTO — solo admin
  // =========================
  Future<void> updateEvento({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    await supabase.from('eventos').update(data).eq('id', id);
  }

  // =========================
  // DELETE EVENTO — solo admin
  // CASCADE elimina usuario_eventos
  // =========================
  Future<void> deleteEvento(int id) async {
    await supabase.from('eventos').delete().eq('id', id);
  }

  // =========================
  // UNIRSE A UN EVENTO
  // Crea la relación usuario ↔ evento
  // =========================
  Future<void> unirseEvento({
    required int eventoId,
    required String userId,
  }) async {
    await supabase.from('usuario_eventos').insert({
      'id_evento': eventoId,
      'id_usuario': userId,
      'reclamado': false,
    });
  }

  // =========================
  // RECLAMAR INSIGNIA DEL EVENTO
  // El usuario marca su participación como reclamada
  // y la insignia se asigna en el repositorio
  // =========================
  Future<void> reclamarInsignia({
    required int eventoId,
    required String userId,
  }) async {
    try {
      // 1. Obtener el id_insignia del evento
      final evento = await supabase
          .from('eventos')
          .select('id_insignia')
          .eq('id', eventoId)
          .single();

      final int? insigniaId = evento['id_insignia'];

      if (insigniaId == null) {
        print('⚠️ El evento no tiene insignia asociada');
        return;
      }

      // 2. Actualizar usuario_eventos (reclamado = true)
      await supabase
          .from('usuario_eventos')
          .update({
            'reclamado': true,
            'fecha_reclamo': DateTime.now().toIso8601String(),
          })
          .eq('id_evento', eventoId)
          .eq('id_usuario', userId);

      // 3. Asignar la insignia al usuario en usuario_insignia
      await supabase.from('usuario_insignia').upsert({
        'id_insignia': insigniaId,
        'id_usuario': userId,
        'fecha_obtenida': DateTime.now().toIso8601String(),
      });

      print('✅ Insignia reclamada y asignada correctamente');
    } catch (e) {
      print('❌ Error reclamando insignia: $e');
      rethrow;
    }
  }

  // =========================
  // ASIGNAR INSIGNIA EN usuario_insignia
  // Se llama desde el repositorio al reclamar
  // =========================
  Future<void> asignarInsigniaUsuario({
    required int insigniaId,
    required String userId,
  }) async {
    // upsert para evitar duplicados si se reclama dos veces
    await supabase.from('usuario_insignia').upsert({
      'id_insignia': insigniaId,
      'id_usuario': userId,
    });
  }

  // =========================
  // VERIFICAR SI YA PARTICIPA
  // =========================
  Future<bool> usuarioParticipa({
    required int eventoId,
    required String userId,
  }) async {
    final response = await supabase
        .from('usuario_eventos')
        .select('id')
        .eq('id_evento', eventoId)
        .eq('id_usuario', userId)
        .maybeSingle();

    return response != null;
  }

  // =========================
  // PARTICIPANTES DE UN EVENTO — admin
  // =========================
  Future<List<Map<String, dynamic>>> getParticipantesDeEvento(
    int eventoId,
  ) async {
    final response = await supabase
        .from('usuario_eventos')
        .select('*, usuarios(id, nombre, email, foto_perfil)')
        .eq('id_evento', eventoId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // =========================
  // HELPER — contar participantes
  // =========================
  Future<int> _contarParticipantes(int eventoId) async {
    final response = await supabase
        .from('usuario_eventos')
        .select('id')
        .eq('id_evento', eventoId);

    return (response as List).length;
  }

  // =========================
  // HELPER — agrega total_participantes a cada evento
  // =========================
  Future<List<Map<String, dynamic>>> _enriquecerConTotal(
    List<Map<String, dynamic>> eventos,
  ) async {
    return Future.wait(
      eventos.map((e) async {
        final total = await _contarParticipantes(e['id'] as int);
        return {...e, 'total_participantes': total};
      }),
    );
  }
}
