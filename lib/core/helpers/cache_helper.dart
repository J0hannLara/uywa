class CacheHelper {

  static bool isExpired({

    required DateTime savedAt,

    required Duration duration,

  }) {

    return DateTime.now().difference(
      savedAt,
    ) > duration;
  }
}