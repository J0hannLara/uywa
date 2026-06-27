import '../../../../core/helpers/cache_helper.dart';

import '../../../../core/constants/cache_duration.dart';

import '../../../../core/cache/cache_service.dart';

class PublicacionesCache {

  static const key =
      'home_feed';

  static Future<void> savePosts(
    List<dynamic> posts,
  ) async {

    await CacheService
        .publicacionesBox
        .put(
      key,
      {

        'saved_at':
            DateTime.now()
                .toIso8601String(),

        'data': posts,
      },
    );
  }

  static List<dynamic>? getPosts() {

    final cache =
        CacheService
            .publicacionesBox
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
              .publicaciones,
    );

    if (expired) {

      CacheService
          .publicacionesBox
          .delete(key);

      return null;
    }

    return List<dynamic>.from(
      cache['data'],
    );
  }

  static Future<void> clear() async {

    await CacheService
        .publicacionesBox
        .delete(key);
  }
}