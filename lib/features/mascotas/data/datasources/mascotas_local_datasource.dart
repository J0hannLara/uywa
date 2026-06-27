import 'package:hive/hive.dart';
import '../../../../core/cache/cache_service.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/constants/cache_duration.dart';

class MascotaLocalDatasource {
  static const _key = 'my_mascotas';

  Box get _box => CacheService.mascotasBox;

  Future<void> saveMascotas(List<Map<String, dynamic>> mascotas) async {
    await _box.put(_key, {
      'saved_at': DateTime.now().toIso8601String(),
      'data': mascotas,
    });
  }

  List<Map<String, dynamic>>? getMascotas() {
    final cache = _box.get(_key);
    if (cache == null) return null;

    final savedAt = DateTime.parse(cache['saved_at']);
    final expired = CacheHelper.isExpired(
      savedAt: savedAt,
      duration: CacheDuration.mascotas,
    );

    if (expired) {
      _box.delete(_key);
      return null;
    }

    return List<Map<String, dynamic>>.from(
      (cache['data'] as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  Future<void> clear() async {
    await _box.delete(_key);
  }
}