import '../../../../core/helpers/cache_helper.dart';

import '../../../../core/constants/cache_duration.dart';

import '../../../../core/cache/cache_service.dart';

class MascotasCache {

  static const key =
      'my_mascotas';

  static Future<void> saveMascotas(
    List<dynamic> mascotas,
  ) async {

    await CacheService.mascotasBox.put(
      key,
      {

        'saved_at':
            DateTime.now()
                .toIso8601String(),

        'data': mascotas,
      },
    );
  }

  static List<dynamic>? getMascotas() {

    final cache =
        CacheService.mascotasBox.get(
      key,
    );

    if (cache == null) {
      return null;
    }

    final savedAt = DateTime.parse(
      cache['saved_at'],
    );

    final expired =
        CacheHelper.isExpired(

      savedAt: savedAt,

      duration:
          CacheDuration.mascotas,
    );

    if (expired) {

      CacheService.mascotasBox
          .delete(key);

      return null;
    }

    return List<dynamic>.from(
      cache['data'],
    );
  }

  static Future<void> clear() async {

    await CacheService
        .mascotasBox
        .delete(key);
  }
}