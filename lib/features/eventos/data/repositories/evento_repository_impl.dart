import '../../domain/repositories/evento_repository.dart';
import '../datasources/evento_remote_datasource.dart';
import '../models/evento_model.dart';
import 'package:mypets/core/cache/hive_cache_service.dart';

class EventoRepositoryImpl implements EventoRepository {
  final EventoRemoteDatasource remoteDatasource;
  final HiveCacheService cacheService;

  EventoRepositoryImpl({
    required this.remoteDatasource,
    required this.cacheService,
  });

  static const String _cacheKeyEventos = 'eventos_cache';
  static const String _cacheKeyEventosAdmin = 'eventos_admin_cache';
  static const Duration _cacheDuration = Duration(minutes: 5);

  // =========================
  // GET EVENTOS ACTIVOS
  // =========================
  @override
  Future<List<EventoModel>> getEventosActivos({
    required String userId,
    int limite = 20,
    int offset = 0,
  }) async {
    try {
      // Intentar obtener desde cache
      final cached = await getCachedEventos();
      if (cached != null && cached.isNotEmpty && offset == 0) {
        return cached;
      }

      // Si no hay cache o es paginación, ir a la API
      final response = await remoteDatasource.getEventosActivos(
        userId: userId,
        limite: limite,
        offset: offset,
      );

      final eventos = response.map((e) => EventoModel.fromJson(e)).toList();

      // Cachear solo si es la primera página
      if (offset == 0) {
        await cacheEventos(eventos);
      }

      return eventos;
    } catch (e) {
      // Si falla la API, intentar cache incluso si está expirado
      final cached = await cacheService.get(_cacheKeyEventos);
      if (cached != null) {
        return cached.map((e) => EventoModel.fromJson(e)).toList();
      }
      rethrow;
    }
  }

  // =========================
  // GET TODOS LOS EVENTOS (Admin)
  // =========================
  @override
   Future<List<EventoModel>> getEventosAdmin({
    int limite = 20,
    int offset = 0,
  }) async {
    try {
      print('📦 [Repository] getEventosAdmin - Iniciando');
      print('📦 [Repository] Parámetros: limite=$limite, offset=$offset');
      
      final cacheKey = '${_cacheKeyEventosAdmin}_$offset';
      print('📦 [Repository] Cache Key: $cacheKey');
      
      // Intentar obtener desde cache
      final cached = await cacheService.get(cacheKey);
      if (cached != null) {
        print('📦 [Repository] Cache HIT - Datos encontrados en cache');
        final List<dynamic> cachedList = cached as List<dynamic>;
        final eventos = cachedList.map((e) => EventoModel.fromJson(e)).toList();
        print('📦 [Repository] Eventos desde cache: ${eventos.length}');
        return eventos;
      }
      
      print('📦 [Repository] Cache MISS - Consultando API');
      
      // Consultar API
      final response = await remoteDatasource.getEventosAdmin(
        limite: limite,
        offset: offset,
      );
      
      print('📦 [Repository] Respuesta API recibida: ${response.length} eventos');
      
      if (response.isEmpty) {
        print('📦 [Repository] ADVERTENCIA: La API devolvió 0 eventos');
      }
      
      final eventos = response.map((e) {
        try {
          return EventoModel.fromJson(e);
        } catch (parseError) {
          print('❌ [Repository] Error parseando evento: $parseError');
          print('❌ [Repository] Datos del evento: $e');
          rethrow;
        }
      }).toList();
      
      print('📦 [Repository] Eventos parseados: ${eventos.length}');
      
      // Cachear solo si hay datos
      if (eventos.isNotEmpty) {
        print('📦 [Repository] Guardando ${eventos.length} eventos en cache');
        await cacheService.put(
          cacheKey,
          eventos.map((e) => e.toJson()).toList(),
          duration: _cacheDuration,
        );
      } else {
        print('📦 [Repository] No se cachean datos vacíos');
      }
      
      return eventos;
      
    } catch (e) {
      print('❌ [Repository] Error en getEventosAdmin: $e');
      print('❌ [Repository] Stacktrace: ${StackTrace.current}');
      
      // Intentar cache incluso si falla la API
      try {
        print('📦 [Repository] Intentando recuperar cache de emergencia');
        final cacheKey = '${_cacheKeyEventosAdmin}_$offset';
        final cached = await cacheService.get(cacheKey);
        if (cached != null) {
          print('📦 [Repository] Cache de emergencia encontrado');
          final List<dynamic> cachedList = cached as List<dynamic>;
          return cachedList.map((e) => EventoModel.fromJson(e)).toList();
        }
        print('📦 [Repository] No hay cache de emergencia');
      } catch (cacheError) {
        print('❌ [Repository] Error en cache de emergencia: $cacheError');
      }
      
      rethrow;
    }
  }

  // =========================
  // GET MIS EVENTOS
  // =========================
  @override
  Future<List<EventoModel>> getMisEventos(String userId) async {
    try {
      final response = await remoteDatasource.getMisEventos(userId);
      return response.map((e) => EventoModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET EVENTO BY ID
  // =========================
  @override
  Future<EventoModel?> getEventoById({
    required int id,
    required String userId,
  }) async {
    try {
      final response = await remoteDatasource.getEventoById(
        id: id,
        userId: userId,
      );
      if (response == null) return null;
      return EventoModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // CREATE EVENTO
  // =========================
  @override
  Future<EventoModel> createEvento(Map<String, dynamic> data) async {
    try {
      final id = await remoteDatasource.createEvento(data);
      final evento = await getEventoById(
        id: id,
        userId: data['id_usuario'] ?? '',
      );
      await clearCache();
      return evento!;
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // UPDATE EVENTO
  // =========================
  @override
  Future<void> updateEvento({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await remoteDatasource.updateEvento(id: id, data: data);
      await clearCache();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // DELETE EVENTO
  // =========================
  @override
  Future<void> deleteEvento(int id) async {
    try {
      await remoteDatasource.deleteEvento(id);
      await clearCache();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // UNIRSE A EVENTO
  // =========================
  @override
  Future<void> unirseEvento({
    required int eventoId,
    required String userId,
  }) async {
    try {
      await remoteDatasource.unirseEvento(eventoId: eventoId, userId: userId);
      await clearCache();
      print('uniendose al eventooo');
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // RECLAMAR INSIGNIA
  // =========================
  @override
  Future<void> reclamarInsignia({
    required int eventoId,
    required String userId,
  }) async {
    try {
      print('reclamando insigniaaaa');
      await remoteDatasource.reclamarInsignia(
        eventoId: eventoId,
        userId: userId,
      );
      await clearCache();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET PARTICIPANTES
  // =========================
  @override
  Future<List<Map<String, dynamic>>> getParticipantesDeEvento(
    int eventoId,
  ) async {
    try {
      return await remoteDatasource.getParticipantesDeEvento(eventoId);
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // CACHE METHODS
  // =========================
  @override
  Future<void> cacheEventos(List<EventoModel> eventos) async {
    await cacheService.put(
      _cacheKeyEventos,
      eventos.map((e) => e.toJson()).toList(),
      duration: _cacheDuration,
    );
  }

  @override
  Future<List<EventoModel>?> getCachedEventos() async {
    final cached = await cacheService.get(_cacheKeyEventos);
    if (cached == null) return null;
    return cached.map((e) => EventoModel.fromJson(e)).toList();
  }

  @override
  Future<void> clearCache() async {
    await cacheService.delete(_cacheKeyEventos);
    // Limpiar cache de admin también
    final keys = await cacheService.getKeys();
    for (final key in keys) {
      if (key.toString().startsWith(_cacheKeyEventosAdmin)) {
        await cacheService.delete(key.toString());
      }
    }
  }
}
