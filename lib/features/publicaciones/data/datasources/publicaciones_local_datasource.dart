import 'package:hive/hive.dart';
import 'package:mypets/core/cache/cache_service.dart';
import 'package:mypets/core/helpers/cache_helper.dart';
import 'package:mypets/core/constants/cache_duration.dart';

class PublicacionLocalDatasource {
  static const _keyFeed = 'feed_global';
  static const _keyMis = 'mis_publicaciones';

  Box get _box => CacheService.publicacionesBox;

  // =========================
  // FEED GLOBAL
  // =========================

  Future<void> saveFeedGlobal(List<Map<String, dynamic>> data) async {
    await _box.put(_keyFeed, {
      'saved_at': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  List<Map<String, dynamic>>? getFeedGlobal() {
    return _getFromBox(_keyFeed);
  }

  // =========================
  // MIS PUBLICACIONES
  // =========================

  Future<void> saveMisPublicaciones(List<Map<String, dynamic>> data) async {
    await _box.put(_keyMis, {
      'saved_at': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  List<Map<String, dynamic>>? getMisPublicaciones() {
    return _getFromBox(_keyMis);
  }

  // =========================
  // CLEAR
  // =========================

  Future<void> clearFeed() async {
    await _box.delete(_keyFeed);
  }

  Future<void> clearMisPublicaciones() async {
    await _box.delete(_keyMis);
  }

  Future<void> clearAll() async {
    await _box.delete(_keyFeed);
    await _box.delete(_keyMis);
  }

  // =========================
  // HELPER INTERNO
  // =========================

  List<Map<String, dynamic>>? _getFromBox(String key) {
    final cache = _box.get(key);
    if (cache == null) return null;

    final savedAt = DateTime.parse(cache['saved_at'] as String);
    final expired = CacheHelper.isExpired(
      savedAt: savedAt,
      duration: CacheDuration.publicaciones,
    );

    if (expired) {
      _box.delete(key);
      return null;
    }

    return List<Map<String, dynamic>>.from(
      (cache['data'] as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }
}