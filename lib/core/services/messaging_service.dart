// lib/core/services/messaging_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class MessagingService {
  static final supabase = Supabase.instance.client;

  // Enviar notificación a todos los usuarios
  static Future<bool> sendNotificationToAll({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _callEdgeFunction(
        title: title,
        body: body,
        data: data,
        targetUsers: [], // Vacío = a todos
      );

      return response['success'] ?? false;
    } catch (e) {
      print('Error enviando notificación: $e');
      return false;
    }
  }

  // Enviar notificación a usuarios específicos
  static Future<bool> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _callEdgeFunction(
        title: title,
        body: body,
        data: data,
        targetUsers: userIds,
      );

      return response['success'] ?? false;
    } catch (e) {
      print('Error enviando notificación: $e');
      return false;
    }
  }

  // Enviar notificación sobre una mascota perdida
  static Future<bool> notifyMascotaPerdida({
    required int perdidaId,
    required String mascotaNombre,
    required int mascotaId,
  }) async {
    final title = '🐾 Mascota perdida';
    final body = 'Se ha reportado a $mascotaNombre como perdido/a';

    final data = {
      'type': 'perdida',
      'perdida_id': perdidaId.toString(),
      'mascota_id': mascotaId.toString(),
      'mascota_nombre': mascotaNombre,
    };

    return await sendNotificationToAll(
      title: title,
      body: body,
      data: data,
    );
  }

  static Future<Map<String, dynamic>> _callEdgeFunction({
    required String title,
    required String body,
    required Map<String, dynamic> data,
    required List<String> targetUsers,
  }) async {
    final response = await supabase.functions.invoke(
      'send-notification',
      body: {
        'title': title,
        'body': body,
        'data': data,
        'targetUsers': targetUsers,
      },
    );

    return response.data as Map<String, dynamic>;
  }
}