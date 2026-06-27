// lib/features/perfiles/presentation/controllers/opciones_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypets/features/auth/presentation/pages/auth_gate_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/session_controller.dart';
import 'package:mypets/core/cache/cache_service.dart';

class OpcionesController extends GetxController {
  final SessionController sessionController = Get.find<SessionController>();
  final supabase = Supabase.instance.client;

  RxBool isLoading = false.obs;
  RxBool notificationsEnabled = true.obs;
  RxBool darkModeEnabled = false.obs;
  RxBool privateAccount = false.obs;
  RxBool showEmail = true.obs;
  RxBool showPhone = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserPreferences();
  }

  void _loadUserPreferences() {
    // Cargar preferencias guardadas localmente
    // Aquí puedes cargar desde SharedPreferences o CacheService
  }

 Future<void> signOut() async {
  try {
    isLoading.value = true;

    await supabase.auth.signOut();

    sessionController.currentUser.value = null;

    await CacheService.clearAll();

    Get.off(AuthGate());

  } catch (e) {
    Get.snackbar(
      'Error',
      'No se pudo cerrar sesión',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    // Guardar preferencia
    await _savePreference('notifications', value);
  }

  Future<void> toggleDarkMode(bool value) async {
    darkModeEnabled.value = value;
  }

  Future<void> togglePrivateAccount(bool value) async {
    privateAccount.value = value;
    await _savePreference('private_account', value);
  }

  Future<void> _savePreference(String key, bool value) async {
    // Implementar guardado en SharedPreferences o CacheService
  }

  void deleteAccount() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta? '
          'Esta acción no se puede deshacer y perderás todos tus datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Implementar lógica de eliminación de cuenta
      isLoading.value = true;
      try {
        // Llamar a tu API para eliminar cuenta
        await Future.delayed(const Duration(seconds: 2));
        await signOut();
      } catch (e) {
        Get.snackbar('Error', 'No se pudo eliminar la cuenta');
      } finally {
        isLoading.value = false;
      }
    }
  }
}