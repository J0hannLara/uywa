// lib/features/albergues/presentation/controllers/albergue_controller.dart
import 'package:get/get.dart';
import '../../data/models/albergues_model.dart';
import '../../domain/usecases/albergue_usecases.dart';
import 'package:mypets/core/services/session_controller.dart';

class AlbergueController extends GetxController {
  // Use cases
  final GetAlberguesPublicos getAlberguesPublicos;
  final GetMisAlbergues getMisAlbergues;
  final GetAlbergueById getAlbergueById;
  final UpdateAlbergue updateAlbergue;
  final AgregarMiembro agregarMiembro;
  final ActualizarRolMiembro actualizarRolMiembro;
  final RemoverMiembro removerMiembro;
  final IngresarMascota ingresarMascota;
  final ActualizarEstadoMascota actualizarEstadoMascota;
  final GetMascotasDeAlbergue getMascotasDeAlbergue; 

  // Dependencies
  
  final SessionController _authController = Get.find<SessionController>();

    AlbergueController({
    required this.getAlberguesPublicos,
    required this.getMisAlbergues,
    required this.getAlbergueById,
    required this.updateAlbergue,
    required this.agregarMiembro,
    required this.actualizarRolMiembro,
    required this.removerMiembro,
    required this.ingresarMascota,
    required this.actualizarEstadoMascota,
    required this.getMascotasDeAlbergue, // 👈 NUEVO
  });

  // =========================
  // ESTADO REACTIVO
  // =========================
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSubmitting = false.obs;

  // Listas de albergues
  final RxList<AlbergueModel> alberguesPublicos = <AlbergueModel>[].obs;
  final RxList<AlbergueModel> misAlbergues = <AlbergueModel>[].obs;
  final Rxn<AlbergueModel> selectedAlbergue = Rxn<AlbergueModel>();

  // Paginación para albergues públicos
  final RxBool hayMasPublicos = true.obs;
  int _offsetPublicos = 0;
  static const int _limite = 10;

  // Mascotas del albergue seleccionado
  final RxList<Map<String, dynamic>> mascotasAlbergue = <Map<String, dynamic>>[].obs;

  // Filtros
  final RxString filtroBusqueda = ''.obs;

  String? get _userId => _authController.currentUser.value?.id;

  @override
  void onInit() {
    super.onInit();
    loadAlberguesPublicos();
    if (_userId != null) {
      loadMisAlbergues();
    }
  }

  // =========================
  // ALBERGUES PÚBLICOS
  // =========================

  Future<void> loadAlberguesPublicos({bool reiniciar = false}) async {
    if (reiniciar) {
      _offsetPublicos = 0;
      hayMasPublicos.value = true;
      alberguesPublicos.clear();
    }

    if (!hayMasPublicos.value) return;

    try {
      isLoading.value = true;

      final result = await getAlberguesPublicos(
        limite: _limite,
        offset: _offsetPublicos,
      );

      alberguesPublicos.addAll(result);
      _offsetPublicos += result.length;

      if (result.length < _limite) hayMasPublicos.value = false;
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los albergues');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cargarMasPublicos() async {
    if (!isLoading.value && !isLoadingMore.value && hayMasPublicos.value) {
      await loadAlberguesPublicos();
    }
  }

  Future<void> refreshAlberguesPublicos() async {
    await loadAlberguesPublicos(reiniciar: true);
  }

  // =========================
  // MIS ALBERGUES
  // =========================

  Future<void> loadMisAlbergues() async {
    if (_userId == null) return;

    try {
      isLoading.value = true;
      final result = await getMisAlbergues(_userId!);
      misAlbergues.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar tus albergues');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMisAlbergues() async {
    await loadMisAlbergues();
  }

  // =========================
  // ALBERGUE POR ID
  // =========================

  Future<void> loadAlbergueById(int id) async {
    try {
      isLoading.value = true;
      final result = await getAlbergueById(id);
      selectedAlbergue.value = result;
      if (result != null) {
        await loadMascotasDeAlbergue(result.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el albergue');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // ACTUALIZAR ALBERGUE
  // =========================

  Future<void> updateAlbergueInfo({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      isSubmitting.value = true;
      await updateAlbergue(id: id, data: data);
      
      // Actualizar en las listas locales
      final indexPublico = alberguesPublicos.indexWhere((a) => a.id == id);
      if (indexPublico != -1) {
        alberguesPublicos[indexPublico] = alberguesPublicos[indexPublico].copyWith(
          nombre: data['nombre'] as String?,
          descripcion: data['descripcion'] as String?,
          telefono: data['telefono'] as String?,
          email: data['email'] as String?,
          imagen: data['imagen'] as String?,
          ubicacion: data['ubicacion'] as String?,
        );
      }
      
      if (selectedAlbergue.value?.id == id) {
        selectedAlbergue.value = selectedAlbergue.value?.copyWith(
          nombre: data['nombre'] as String?,
          descripcion: data['descripcion'] as String?,
          telefono: data['telefono'] as String?,
          email: data['email'] as String?,
          imagen: data['imagen'] as String?,
          ubicacion: data['ubicacion'] as String?,
        );
      }
      
      Get.snackbar('Éxito', 'Albergue actualizado correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el albergue');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // MIEMBROS
  // =========================

  Future<void> agregarMiembroAlbergue({
    required int albergueId,
    required String userId,
    required String rol,
  }) async {
    try {
      isSubmitting.value = true;
      await agregarMiembro(
        albergueId: albergueId,
        userId: userId,
        rol: rol,
      );
      
      // Recargar detalles del albergue
      if (selectedAlbergue.value?.id == albergueId) {
        await loadAlbergueById(albergueId);
      }
      
      Get.snackbar('Éxito', 'Miembro agregado correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo agregar el miembro');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> removerMiembroAlbergue({
    required int albergueId,
    required String userId,
  }) async {
    try {
      isSubmitting.value = true;
      await removerMiembro(
        albergueId: albergueId,
        userId: userId,
      );
      
      if (selectedAlbergue.value?.id == albergueId) {
        await loadAlbergueById(albergueId);
      }
      
      Get.snackbar('Éxito', 'Miembro removido correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo remover el miembro');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // MASCOTAS EN ALBERGUE
  // =========================

  Future<void> loadMascotasDeAlbergue(int albergueId) async {
    try {
      final result = await getMascotasDeAlbergue(albergueId);
      mascotasAlbergue.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las mascotas');
    }
  }

  Future<void> ingresarMascotaAlbergue({
    required int mascotaId,
    required int albergueId,
  }) async {
    try {
      isSubmitting.value = true;
      await ingresarMascota(
        mascotaId: mascotaId,
        albergueId: albergueId,
      );
      
      await loadMascotasDeAlbergue(albergueId);
      Get.snackbar('Éxito', 'Mascota ingresada al albergue');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo ingresar la mascota');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> actualizarEstadoMascotaAlbergue({
    required int mascotaAlbergueId,
    required String nuevoEstado,
    DateTime? fechaSalida,
  }) async {
    try {
      isSubmitting.value = true;
      await actualizarEstadoMascota(
        mascotaAlbergueId: mascotaAlbergueId,
        nuevoEstado: nuevoEstado,
        fechaSalida: fechaSalida,
      );
      
      if (selectedAlbergue.value != null) {
        await loadMascotasDeAlbergue(selectedAlbergue.value!.id);
      }
      
      Get.snackbar('Éxito', 'Estado actualizado correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el estado');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // UTILIDADES
  // =========================

  List<AlbergueModel> get alberguesFiltrados {
    if (filtroBusqueda.value.isEmpty) {
      return alberguesPublicos;
    }
    return alberguesPublicos
        .where((a) =>
            a.nombre
                .toLowerCase()
                .contains(filtroBusqueda.value.toLowerCase()) ||
            (a.ubicacion?.toLowerCase() ?? '')
                .contains(filtroBusqueda.value.toLowerCase()))
        .toList();
  }

  bool esAdminDeAlbergue(int albergueId) {
    if (_userId == null) return false;
    final albergue = alberguesPublicos.firstWhereOrNull((a) => a.id == albergueId);
    return albergue?.esAdmin(_userId!) ?? false;
  }

  String? getRolEnAlbergue(int albergueId) {
    if (_userId == null) return null;
    final albergue = alberguesPublicos.firstWhereOrNull((a) => a.id == albergueId);
    return albergue?.getRolUsuario(_userId!);
  }
}