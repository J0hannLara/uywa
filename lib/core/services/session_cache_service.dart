import '../cache/cache_service.dart';

class SessionCacheService {

  // GUARDAR USUARIO

  static Future<void> saveUser(
    Map<String, dynamic> user,
  ) async {

    await CacheService.sessionBox.put(
      'current_user',
      user,
    );
  }

  // OBTENER USUARIO

  static Map<String, dynamic>? getUser() {

    final data =
        CacheService.sessionBox.get(
      'current_user',
    );

    if (data == null) return null;

    return Map<String, dynamic>.from(
      data,
    );
  }

  // ELIMINAR USUARIO

  static Future<void> clearUser() async {

    await CacheService.sessionBox.delete(
      'current_user',
    );
  }
}