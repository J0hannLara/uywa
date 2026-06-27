import 'package:hive_flutter/hive_flutter.dart';

class CacheService {

  static Future<void> init() async {

    await Hive.initFlutter();

    await Hive.openBox('session');

    await Hive.openBox('usuarios');

    await Hive.openBox('mascotas');

    await Hive.openBox('publicaciones');

    await Hive.openBox('notificaciones');

    await Hive.openBox('config');
  }

  // SESSION

  static Box get sessionBox =>
      Hive.box('session');

  // USUARIOS

  static Box get usuariosBox =>
      Hive.box('usuarios');

  // MASCOTAS

  static Box get mascotasBox =>
      Hive.box('mascotas');

  // PUBLICACIONES

  static Box get publicacionesBox =>
      Hive.box('publicaciones');

  // NOTIFICACIONES

  static Box get notificacionesBox =>
      Hive.box('notificaciones');

  // CONFIG

  static Box get configBox =>
      Hive.box('config');

  // LIMPIAR TODO

  static Future<void> clearAll() async {

    await sessionBox.clear();

    await usuariosBox.clear();

    await mascotasBox.clear();

    await publicacionesBox.clear();

    await notificacionesBox.clear();

    await configBox.clear();
  }
}