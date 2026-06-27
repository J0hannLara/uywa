import 'package:get/get.dart';
import 'package:mypets/core/services/session_controller.dart';
import '../../domain/repositories/perdidas_repository.dart';
import '../../data/models/perdidas_model.dart';

class PerdidaController extends GetxController {
  final PerdidaRepository repository;
  final SessionController _authController = Get.find<SessionController>();

  PerdidaController({required this.repository});

  String? get _userId => _authController.currentUser.value?.id;

  // =========================
  // ESTADO REACTIVO
  // =========================
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxList<PerdidaModel> perdidas = <PerdidaModel>[].obs;
  final RxList<PerdidaModel> perdidasDeMascota = <PerdidaModel>[].obs;
  final Rxn<PerdidaModel> selectedPerdida = Rxn<PerdidaModel>();

  final RxnString filtroEstado = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadPerdidas();
  }

  // =========================
  // LOAD TODAS — feed público de pérdidas
  // =========================
  Future<void> loadPerdidas({String? estado}) async {
    try {
      isLoading.value = true;
      filtroEstado.value = estado;

      final result = await repository.getPerdidas(estadoFiltro: estado);
      perdidas.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las pérdidas');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // LOAD POR MASCOTA — historial de una mascota
  // =========================
  Future<void> loadPerdidasDeMascota(int mascotaId) async {
    try {
      isLoading.value = true;
      final result = await repository.getPerdidasPorMascota(mascotaId);
      perdidasDeMascota.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el historial');
    } finally {
      isLoading.value = false;
    }
  }

  Future<PerdidaModel?> getPerdidaById(int id) async {
    try {
      isLoading.value = true;
      final result = await repository.getPerdidaById(id);
      if (result != null) {
        selectedPerdida.value = result;
      }
      return result;
    } catch (e) {
      print('Error obteniendo pérdida: $e');
      Get.snackbar('Error', 'No se pudo cargar la pérdida');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // También agrega este método para select por ID
  Future<void> selectPerdidaById(int id) async {
    await getPerdidaById(id);
  }

  // =========================
  // FILTRAR POR ESTADO
  // =========================
  Future<void> aplicarFiltro(String? estado) async {
    await loadPerdidas(estado: estado);
  }

  // =========================
  // REFRESH
  // =========================
  Future<void> refreshPerdidas() async {
    await loadPerdidas(estado: filtroEstado.value);
  }

  // =========================
  // CREATE
  // El usuario reporta que su mascota se perdió
  // =========================
  Future<void> createPerdida({
    required int idMascota,
    required DateTime fechaPerdida,
    required String lugarPerdida,
    String? descripcionPerdida,
    double? latitud,
    double? longitud,
    int radioBusquedaKm = 5,
    double? recompensa,
  }) async {
    final userId = _userId;
    if (userId == null) {
      Get.snackbar('Error', 'Debes iniciar sesión');
      return;
    }

    try {
      isSubmitting.value = true;

      await repository.createPerdida(
        idMascota: idMascota,
        fechaPerdida: fechaPerdida,
        lugarPerdida: lugarPerdida,
        descripcionPerdida: descripcionPerdida,
        latitud: latitud,
        longitud: longitud,
        radioBusquedaKm: radioBusquedaKm,
        recompensa: recompensa,
      );

      await loadPerdidas(estado: filtroEstado.value);
      Get.snackbar('Éxito', 'Reporte de pérdida creado correctamente');
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear el reporte de pérdida');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // UPDATE
  // =========================
  Future<void> updatePerdida({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      isSubmitting.value = true;

      await repository.updatePerdida(id: id, data: data);
      await loadPerdidas(estado: filtroEstado.value);

      Get.snackbar('Éxito', 'Reporte actualizado correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el reporte');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // MARCAR COMO ENCONTRADA
  // =========================
  Future<void> marcarComoEncontrada({required int id, String? detalles}) async {
    try {
      isSubmitting.value = true;

      await repository.marcarComoEncontrada(id: id, detalles: detalles);

      // Actualizar localmente sin recargar todo
      final index = perdidas.indexWhere((p) => p.id == id);
      if (index != -1) {
        perdidas[index] = perdidas[index].copyWith(
          estado: 'encontrada',
          fechaEncontrado: DateTime.now(),
          detallesEncontrado: detalles,
        );
      }

      Get.snackbar('¡Buenas noticias!', 'Mascota marcada como encontrada');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el estado');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // CERRAR REPORTE
  // =========================
  Future<void> cerrarReporte(int id) async {
    await updatePerdida(id: id, data: {'estado': 'cerrada'});
  }

  // =========================
  // DELETE
  // =========================
  Future<void> deletePerdida(int id) async {
    try {
      isSubmitting.value = true;

      await repository.deletePerdida(id);
      perdidas.removeWhere((p) => p.id == id);

      Get.snackbar('Éxito', 'Reporte eliminado correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar el reporte');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // SELECT
  // =========================
  void selectPerdida(PerdidaModel perdida) {
    selectedPerdida.value = perdida;
  }

  void clearSelected() {
    selectedPerdida.value = null;
  }
}
