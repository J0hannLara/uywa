import '../../../../core/helpers/cache_helper.dart';

import '../../../../core/constants/cache_duration.dart';

import '../../../../core/cache/cache_service.dart';

class NotificacionesCache {

  static const key =
      'notifications';

  static Future<void> save(
    List<dynamic> data,
  ) async {

    await CacheService
        .notificacionesBox
        .put(
      key,
      {

        'saved_at':
            DateTime.now()
                .toIso8601String(),

        'data': data,
      },
    );
  }

  static List<dynamic>? get() {

    final cache =
        CacheService
            .notificacionesBox
            .get(key);

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
          CacheDuration
              .notificaciones,
    );

    if (expired) {

      CacheService
          .notificacionesBox
          .delete(key);

      return null;
    }

    return List<dynamic>.from(
      cache['data'],
    );
  }

  static Future<void> clear() async {

    await CacheService
        .notificacionesBox
        .delete(key);
  }
}