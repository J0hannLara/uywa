// lib/core/cache/hive_cache_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class HiveCacheService {
  static const String _defaultBox = 'app_cache';
  late Box _box;

  HiveCacheService._internal();

  static final HiveCacheService _instance = HiveCacheService._internal();

  factory HiveCacheService() => _instance;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_defaultBox);
  }

  // Guardar con tiempo de expiración
  Future<void> put(
    String key,
    dynamic value, {
    Duration? duration,
  }) async {
    final data = {
      'value': value,
      'expires_at': duration != null
          ? DateTime.now().add(duration).toIso8601String()
          : null,
    };
    await _box.put(key, json.encode(data));
  }

  // Obtener con validación de expiración
  Future<dynamic> get(String key) async {
    final raw = _box.get(key);
    if (raw == null) return null;

    try {
      final data = json.decode(raw);
      final expiresAt = data['expires_at'];

      // Verificar expiración
      if (expiresAt != null) {
        final expiry = DateTime.parse(expiresAt);
        if (DateTime.now().isAfter(expiry)) {
          await _box.delete(key);
          return null;
        }
      }

      return data['value'];
    } catch (e) {
      return null;
    }
  }

  // Eliminar
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  // Obtener todas las keys
  Future<List<dynamic>> getKeys() async {
    return _box.keys.toList();
  }

  // Limpiar todo
  Future<void> clear() async {
    await _box.clear();
  }
}