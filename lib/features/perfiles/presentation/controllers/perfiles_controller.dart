import 'dart:io';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mypets/core/services/session_cache_service.dart';
import '../../../../core/services/session_controller.dart';
import '../../../../core/services/storage_service.dart';
import 'package:mypets/features/auth/data/models/usuario_model.dart';
import '../../domain/repositories/profile_repository.dart';
import 'package:mypets/core/helpers/main_navigation_helper.dart';

class ProfileController extends GetxController {
  final ProfileRepository repository = Get.find<ProfileRepository>();

  final session = Get.find<SessionController>();

  final storageService = Get.find<StorageService>();

  final supabase = Supabase.instance.client;
  

  RxBool isLoading = false.obs;

  Rxn<UsuarioModel> profile = Rxn<UsuarioModel>();

  @override
  void onInit() {
    super.onInit();

    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    try {
      isLoading.value = true;

      // 1 CACHE PRIMERO

      final cached = SessionCacheService.getUser();

      if (cached != null) {
        final usuario = UsuarioModel.fromJson(cached);

        profile.value = usuario;

        session.currentUser.value = usuario;

        print('Usuario desde CACHE');
      }

      // 2 API

      final authUser = supabase.auth.currentUser;

      if (authUser == null) return;

      final usuario = await repository.getCurrentUser(authUser.id);

      if (usuario != null) {
        profile.value = usuario;

        session.currentUser.value = usuario;

        // GUARDAR CACHE

        await SessionCacheService.saveUser(usuario.toJson());

        print('Usuario desde API');
      }
    } catch (e) {
      print('ERROR cargarUsuario: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeStep1({
    required String nombre,

    required String telefono,

    required String ciudad,

    required String pais,
  }) async {
    try {
      isLoading.value = true;

      final authUser = supabase.auth.currentUser;

      if (authUser == null) return;

      await repository.updateBasicInfo(
        userId: authUser.id,

        nombre: nombre,

        telefono: telefono,

        ciudad: ciudad,

        pais: pais,
      );

      await cargarUsuario();
    } catch (e) {
      print(e);

      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeStep2({
    required String username,
    required String descripcion,
    File? avatar,
    String? avatarUrl, // 👈 NUEVO: para URLs de Google o paths de assets
  }) async {
    try {
      isLoading.value = true;

      final user = supabase.auth.currentUser;
      if (user == null) return;

      final exists = await repository.usernameExists(
        username: username,
        currentUserId: user.id,
      );

      if (exists) {
        Get.snackbar('Username ocupado', 'Elige otro username');
        return;
      }

      String? imageUrl;

      // Caso 2: Se seleccionó una URL de Google o path de asset
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        imageUrl = avatarUrl; // Guardar la URL o path directamente
      }

      await repository.updateProfileInfo(
        userId: user.id,
        username: username,
        descripcion: descripcion,
        fotoPerfil: imageUrl,
      );

      await cargarUsuario();

      Get.snackbar('Éxito', 'Perfil completado correctamente');
    } catch (e) {
      print(e);
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> finishOnboarding() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      await supabase
          .from('usuarios')
          .update({'onboarding_step': 4})
          .eq('id', user.id);

      await cargarUsuario();
      await goToMainApp();
    } catch (e) {
      print('ERROR finishOnboarding: $e');
    }
  }
}
