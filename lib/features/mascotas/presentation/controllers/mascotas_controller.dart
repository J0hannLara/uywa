import 'dart:io';
import 'package:get/get.dart';
import '../../data/models/mascotas_model.dart';
import '../../domain/repositories/mascotas_repository.dart';
import 'package:mypets/core/services/session_controller.dart';
import 'package:mypets/features/perfiles/presentation/controllers/perfiles_controller.dart';

class MascotaController extends GetxController {
  final MascotaRepository repository;

  final SessionController session = Get.find<SessionController>();
  final ProfileController profileController = Get.find<ProfileController>();
  MascotaController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxList<MascotaModel> mascotas = <MascotaModel>[].obs;
  final Rxn<MascotaModel> selectedMascota = Rxn<MascotaModel>();

  String? get _userId => session.currentUser.value?.id;

  @override
  void onInit() {
    super.onInit();
    loadMascotas();
  }

  // =========================
  // LOAD MASCOTAS
  // =========================

  Future<void> loadMascotas() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final result = await repository.getMascotas(userId);
      mascotas.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las mascotas');
    } finally {
      isLoading.value = false;
    }
  }

  Future<MascotaModel?> getMascotaById(int id) async {
    try {
      isLoading.value = true;
      final result = await repository.getMascotaById(id);
      return result;
    } catch (e) {
      print('Error obteniendo mascota: $e');
      Get.snackbar('Error', 'No se pudo cargar la mascota');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // REFRESH
  // Limpia cache y recarga desde API
  // =========================

  Future<void> refreshMascotas() async {
    await repository.clearCache();
    await loadMascotas();
  }

  // =========================
  // CREATE
  // =========================

  Future<void> createMascota({
    required String nombre,
    required String descripcion,
    required String tipo,
    required String sexo,
    required String raza,
    required String color,
    required int? edad,
    required String edadTiempo,
    required String tamano,
    required double? peso,
    required bool esterilizado,
    required bool vacunado,
    required String microchip,
    File? imagen,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      isLoading.value = true;

      await repository.createMascota(
        data: {
          'nombre': nombre,
          'descripcion': descripcion,
          'tipo': tipo,
          'sexo': sexo,
          'raza': raza,
          'color': color,
          'edad': edad,
          'edad_tiempo': edadTiempo,
          'tamano': tamano,
          'peso': peso,
          'esterilizado': esterilizado,
          'vacunado': vacunado,
          'microchip': microchip,
        },
        imagen: imagen,
        userId: userId,
      );

      await loadMascotas();
      Get.snackbar('Éxito', 'Mascota registrada correctamente');

      // 👈 Usar la instancia existente de ProfileController
      await profileController.finishOnboarding();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo registrar la mascota');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> updateMascota({
    required int mascotaId,
    required Map<String, dynamic> data,
    File? nuevaImagen,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      isLoading.value = true;

      await repository.updateMascota(
        id: mascotaId,
        data: data,
        nuevaImagen: nuevaImagen,
        userId: userId,
      );

      await loadMascotas();
      Get.snackbar('Éxito', 'Mascota actualizada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar la mascota');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // DELETE
  // =========================

  Future<void> deleteMascota(int mascotaId) async {
    try {
      isLoading.value = true;

      await repository.deleteMascota(mascotaId);

      mascotas.removeWhere((e) => e.id == mascotaId);
      Get.snackbar('Éxito', 'Mascota eliminada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar la mascota');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // SELECT MASCOTA
  // =========================

  void selectMascota(MascotaModel mascota) {
    selectedMascota.value = mascota;
  }

  void clearSelected() {
    selectedMascota.value = null;
  }
}
