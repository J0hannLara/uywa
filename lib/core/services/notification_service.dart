// lib/core/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mypets/features/mascotas/presentation/pages/mascota_detail_page.dart';
import 'package:mypets/features/perdidas/presentation/pages/perdida_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Solicitar permisos
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('❌ Notificaciones denegadas');
      return;
    }

    print('✅ Notificaciones autorizadas');

    // Inicializar notificaciones locales
    await _initializeLocalNotifications();

    // Escuchar mensajes en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Escuchar cuando el usuario toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // Obtener token y guardar en Supabase
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveTokenToSupabase(token);
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📩 Notificación en foreground: ${message.notification?.title}');
    await _showLocalNotification(
      title: message.notification?.title ?? 'Nueva notificación',
      body: message.notification?.body ?? '',
      payload: message.data['type'] ?? '',
    );
  }

  static void _handleMessageOpened(RemoteMessage message) {
    print('📩 Notificación abierta: ${message.notification?.title}');
    _navigateToScreen(message.data);
  }

  static void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      _navigateToScreen({'type': response.payload});
    }
  }

  static void _navigateToScreen(Map<String, dynamic> data) {
    final type = data['type'];
    
    switch (type) {
      case 'perdida':
        final perdidaId = data['perdida_id'];
        if (perdidaId != null) {
          // 👈 Usar Get.to() directamente
          Get.to(
            () => const PerdidaDetallePage(),
            arguments: {'id': int.parse(perdidaId.toString())},
          );
        } else {
          Get.toNamed('/perdidas');
        }
        break;
      case 'test':
        // Notificación de prueba - no navegar
        break;
        
      default:
        Get.toNamed('/home');
    }
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'perdidas_channel',
      'Mascotas perdidas',
      channelDescription: 'Notificaciones de mascotas perdidas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> _saveTokenToSupabase(String token) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Verificar si el token ya existe
      final existing = await supabase
          .from('dispositivos')
          .select()
          .eq('token', token)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        await supabase
            .from('dispositivos')
            .update({
              'updated_at': DateTime.now().toIso8601String(),
              'activo': true,
            })
            .eq('token', token);
      } else {
        // Insertar
        await supabase.from('dispositivos').insert({
          'id_usuario': user.id,
          'token': token,
          'plataforma': _getPlatform(),
          'activo': true,
        });
      }

      print('✅ Token guardado en Supabase');
    } catch (e) {
      print('❌ Error guardando token: $e');
    }
  }

  static String _getPlatform() {
    if (GetPlatform.isAndroid) return 'android';
    if (GetPlatform.isIOS) return 'ios';
    if (GetPlatform.isWeb) return 'web';
    return 'unknown';
  }
}