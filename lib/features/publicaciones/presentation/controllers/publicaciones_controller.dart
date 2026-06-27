import 'dart:io';
import 'package:get/get.dart';
import 'package:mypets/features/home/navigation/main_navigation_page.dart';
import '../../domain/repositories/publicaciones_repository.dart';
import '../../data/models/publicaciones_model.dart';
import 'package:mypets/core/services/session_controller.dart';

class PublicacionController extends GetxController {
  final PublicacionRepository repository;
  final SessionController _authController = Get.find<SessionController>();

  PublicacionController({required this.repository});

  // =========================
  // ESTADO REACTIVO
  // =========================
  final RxBool isLoadingFeed = false.obs;
  final RxBool isLoadingMis = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxList<PublicacionModel> feedGlobal = <PublicacionModel>[].obs;
  final RxList<PublicacionModel> misPublicaciones = <PublicacionModel>[].obs;
  final Rxn<PublicacionModel> selectedPublicacion = Rxn<PublicacionModel>();

  // Paginación
  final RxBool hayMasFeed = true.obs;
  final RxBool hayMasMis = true.obs;
  int _offsetFeed = 0;
  int _offsetMis = 0;
  static const int _limite = 20;

  // Filtro activo del feed
  final RxnString filtroTipo = RxnString();

  String? get _userId => _authController.currentUser.value?.id;

  @override
  void onInit() {
    super.onInit();
    loadFeedGlobal();
    loadMisPublicaciones();
  }

  // =========================
  // FEED GLOBAL
  // =========================

  Future<void> loadFeedGlobal({bool reiniciar = false}) async {
    if (reiniciar) {
      _offsetFeed = 0;
      hayMasFeed.value = true;
      feedGlobal.clear();
    }

    if (!hayMasFeed.value) return;

    try {
      isLoadingFeed.value = true;

      final result = await repository.getFeedGlobal(
        limite: _limite,
        offset: _offsetFeed,
        tipoFiltro: filtroTipo.value,
      );

      feedGlobal.addAll(result);
      _offsetFeed += result.length;

      // Si devolvió menos del límite ya no hay más páginas
      if (result.length < _limite) hayMasFeed.value = false;
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el feed');
    } finally {
      isLoadingFeed.value = false;
    }
  }

  // Siguiente página del feed
  Future<void> cargarMasFeed() async {
    await loadFeedGlobal();
  }

  // Refrescar feed desde cero limpiando cache
  Future<void> refreshFeed() async {
    await repository.clearCache();
    await loadFeedGlobal(reiniciar: true);
  }

  // Aplicar filtro por tipo de publicación
  Future<void> aplicarFiltro(String? tipo) async {
    filtroTipo.value = tipo;
    await repository.clearCache();
    await loadFeedGlobal(reiniciar: true);
  }

  // =========================
  // MIS PUBLICACIONES
  // =========================

  Future<void> loadMisPublicaciones({bool reiniciar = false}) async {
    final userId = _userId;
    if (userId == null) return;

    if (reiniciar) {
      _offsetMis = 0;
      hayMasMis.value = true;
      misPublicaciones.clear();
    }

    if (!hayMasMis.value) return;

    try {
      isLoadingMis.value = true;

      final result = await repository.getMisPublicaciones(
        userId,
        limite: _limite,
        offset: _offsetMis,
      );

      misPublicaciones.addAll(result);
      _offsetMis += result.length;

      if (result.length < _limite) hayMasMis.value = false;
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar tus publicaciones');
    } finally {
      isLoadingMis.value = false;
    }
  }

  Future<void> cargarMasMis() async {
    await loadMisPublicaciones();
  }

  Future<void> refreshMisPublicaciones() async {
    await repository.clearCache();
    await loadMisPublicaciones(reiniciar: true);
  }

  // =========================
  // CREATE
  // =========================

  Future<void> createPublicacion({
    required String tipoPublicacion,
    required String titulo,
    String? descripcion,
    String? ubicacionTexto,
    double? latitud,
    double? longitud,
    int? idMascota,
    List<File> imagenes = const [],
  }) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      isSubmitting.value = true;

      await repository.createPublicacion(
        data: {
          'tipo_publicacion': tipoPublicacion,
          'titulo': titulo,
          if (descripcion != null) 'descripcion': descripcion,
          if (ubicacionTexto != null) 'ubicacion_texto': ubicacionTexto,
          if (latitud != null) 'latitud': latitud,
          if (longitud != null) 'longitud': longitud,
        },
        userId: userId,
        idMascota: idMascota,
        imagenes: imagenes,
      );

      // Refrescar ambas listas
      await Future.wait([
        loadFeedGlobal(reiniciar: true),
        loadMisPublicaciones(reiniciar: true),
      ]);

      Get.snackbar('Éxito', 'Publicación creada correctamente');
      Get.back();
      await Get.offAll(() => const MainNavigationPage());
    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear la publicación');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> updatePublicacion({
    required int id,
    required Map<String, dynamic> data,
    List<File> nuevasImagenes = const [],
  }) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      isSubmitting.value = true;

      await repository.updatePublicacion(
        id: id,
        data: data,
        nuevasImagenes: nuevasImagenes,
        userId: userId,
      );

      await Future.wait([
        loadFeedGlobal(reiniciar: true),
        loadMisPublicaciones(reiniciar: true),
      ]);

      Get.snackbar('Éxito', 'Publicación actualizada correctamente');
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar la publicación');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // DELETE
  // =========================

  Future<void> deletePublicacion(int id) async {
    try {
      isSubmitting.value = true;

      await repository.deletePublicacion(id);

      // Remover de ambas listas sin refrescar todo
      feedGlobal.removeWhere((p) => p.id == id);
      misPublicaciones.removeWhere((p) => p.id == id);

      Get.snackbar('Éxito', 'Publicación eliminada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar la publicación');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // SELECT / DETALLE
  // =========================

  Future<void> selectPublicacion(int id) async {
    try {
      final pub = await repository.getPublicacionById(id);
      if (pub != null) {
        selectedPublicacion.value = pub;
        // Registrar visualización en segundo plano
        repository.incrementarVisualizacion(id);
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar la publicación');
    }
  }

  void clearSelected() {
    selectedPublicacion.value = null;
  }
}