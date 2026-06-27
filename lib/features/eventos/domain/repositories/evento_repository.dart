import '../../data/models/evento_model.dart';

abstract class EventoRepository {
  // =========================
  // GET EVENTOS ACTIVOS
  // =========================
  Future<List<EventoModel>> getEventosActivos({
    required String userId,
    int limite = 20,
    int offset = 0,
  });

  // =========================
  // GET TODOS LOS EVENTOS (Admin)
  // =========================
  Future<List<EventoModel>> getEventosAdmin({
    int limite = 20,
    int offset = 0,
  });
  

  // =========================
  // GET MIS EVENTOS
  // =========================
  Future<List<EventoModel>> getMisEventos(String userId);

  // =========================
  // GET EVENTO BY ID
  // =========================
  Future<EventoModel?> getEventoById({
    required int id,
    required String userId,
  });

  // =========================
  // CREATE EVENTO
  // =========================
  Future<EventoModel> createEvento(Map<String, dynamic> data);

  // =========================
  // UPDATE EVENTO
  // =========================
  Future<void> updateEvento({
    required int id,
    required Map<String, dynamic> data,
  });

  // =========================
  // DELETE EVENTO
  // =========================
  Future<void> deleteEvento(int id);

  // =========================
  // UNIRSE A EVENTO
  // =========================
  Future<void> unirseEvento({
    required int eventoId,
    required String userId,
  });

  // =========================
  // RECLAMAR INSIGNIA
  // =========================
  Future<void> reclamarInsignia({
    required int eventoId,
    required String userId,
  });

  // =========================
  // GET PARTICIPANTES
  // =========================
  Future<List<Map<String, dynamic>>> getParticipantesDeEvento(int eventoId);

  // =========================
  // CACHE
  // =========================
  Future<void> cacheEventos(List<EventoModel> eventos);
  Future<List<EventoModel>?> getCachedEventos();
  Future<void> clearCache();
}