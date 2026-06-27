import 'package:get/get.dart';
import 'package:mypets/core/services/session_controller.dart';
import '../../domain/repositories/insignias_repository.dart';
import '../../data/models/insignias_model.dart';

class InsigniaController extends GetxController {
  final InsigniaRepository repository;

  final SessionController _authController = Get.find<SessionController>();

  InsigniaController({required this.repository});

  String? get _userId => _authController.currentUser.value?.id;

  // =========================
  // ESTADO REACTIVO
  // =========================
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // Lista general — panel admin y vista pública
  final RxList<InsigniaModel> insignias = <InsigniaModel>[].obs;

  // Insignias de un usuario específico — vista perfil
  final RxList<InsigniaModel> insigniasDeUsuario = <InsigniaModel>[].obs;

  // Usuarios que tienen una insignia — panel admin
  final RxList<UsuarioInsigniaModel> usuariosDeInsignia =
      <UsuarioInsigniaModel>[].obs;

  final Rxn<InsigniaModel> selectedInsignia = Rxn<InsigniaModel>();

  // Filtro activo por tipo
  final RxnString filtroTipo = RxnString();

  final RxBool insigniasCargadas = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInsignias();
  }

  // =========================
  // LOAD TODAS LAS INSIGNIAS
  // Pública — no requiere auth
  // =========================
  Future<void> loadInsignias({String? tipo}) async {
    try {
      isLoading.value = true;
      filtroTipo.value = tipo;
      final result = await repository.getInsignias(tipoFiltro: tipo);
      insignias.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las insignias');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // LOAD INSIGNIAS DE UN USUARIO
  // Para perfil público o propio
  // =========================
  Future<void> loadInsigniasDeUsuario(String userId) async {
    if (insigniasCargadas.value) return;

    try {
      isLoading.value = true;
      final result = await repository.getInsigniasDeUsuario(userId);
      insigniasDeUsuario.assignAll(result);
      insigniasCargadas.value = true;
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las insignias del usuario');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // LOAD USUARIOS DE UNA INSIGNIA
  // Panel admin — ver quién tiene una insignia
  // =========================
  Future<void> loadUsuariosDeInsignia(int insigniaId) async {
    try {
      isLoading.value = true;
      final result = await repository.getUsuariosDeInsignia(insigniaId);
      usuariosDeInsignia.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los usuarios');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // GET INSIGNIA BY ID
  // =========================
  Future<InsigniaModel?> getInsigniaById(int id) async {
    try {
      final result = await repository.getInsigniaById(id);
      return result;
    } catch (e) {
      print('Error obteniendo insignia: $e');
      return null;
    }
  }

  // =========================
  // VERIFICAR SI USUARIO TIENE INSIGNIA
  // =========================
  Future<bool> usuarioTieneInsignia(int insigniaId, String userId) async {
    try {
      final usuarios = await repository.getUsuariosDeInsignia(insigniaId);
      return usuarios.any((u) => u.idUsuario == userId);
    } catch (e) {
      print('Error verificando insignia: $e');
      return false;
    }
  }

  // =========================
  // SELECT INSIGNIA
  // =========================
  void selectInsignia(InsigniaModel insignia) {
    selectedInsignia.value = insignia;
  }

  void clearSelected() {
    selectedInsignia.value = null;
    usuariosDeInsignia.clear();
  }

  // =========================
  // CREATE — solo admin
  // =========================
  Future<void> createInsignia({
    required String nombre,
    String? descripcion,
    String? imagen,
    String? tipo,
  }) async {
    final userId = _userId;
    if (userId == null) {
      Get.snackbar('Error', 'Debes iniciar sesión');
      return;
    }

    try {
      isSubmitting.value = true;

      await repository.createInsignia({
        'nombre': nombre,
        if (descripcion != null) 'descripcion': descripcion,
        if (imagen != null) 'imagen': imagen,
        if (tipo != null) 'tipo': tipo,
      });

      await loadInsignias(tipo: filtroTipo.value);
      Get.snackbar('Éxito', 'Insignia creada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear la insignia');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // UPDATE — solo admin
  // =========================
  Future<void> updateInsignia({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final userId = _userId;
    if (userId == null) {
      Get.snackbar('Error', 'Debes iniciar sesión');
      return;
    }

    try {
      isSubmitting.value = true;

      await repository.updateInsignia(id: id, data: data);

      // Actualizar en lista local sin recargar todo
      final index = insignias.indexWhere((i) => i.id == id);
      if (index != -1) {
        final actual = insignias[index];
        insignias[index] = actual.copyWith(
          nombre: data['nombre'] as String?,
          descripcion: data['descripcion'] as String?,
          imagen: data['imagen'] as String?,
          tipo: data['tipo'] as String?,
        );
      }

      Get.snackbar('Éxito', 'Insignia actualizada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar la insignia');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // DELETE — solo admin
  // =========================
  Future<void> deleteInsignia(int id) async {
    final userId = _userId;
    if (userId == null) {
      Get.snackbar('Error', 'Debes iniciar sesión');
      return;
    }

    try {
      isSubmitting.value = true;

      await repository.deleteInsignia(id);
      insignias.removeWhere((i) => i.id == id);

      Get.snackbar('Éxito', 'Insignia eliminada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar la insignia');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // ASIGNAR A USUARIO — solo admin
  // =========================
  Future<void> asignarInsignia({
    required int insigniaId,
    required String userId,
  }) async {
    final adminId = _userId;
    if (adminId == null) {
      Get.snackbar('Error', 'Debes iniciar sesión');
      return;
    }

    try {
      isSubmitting.value = true;

      await repository.asignarInsignia(insigniaId: insigniaId, userId: userId);

      // Recargar usuarios de esta insignia si está seleccionada
      if (selectedInsignia.value?.id == insigniaId) {
        await loadUsuariosDeInsignia(insigniaId);
      }

      Get.snackbar('Éxito', 'Insignia asignada correctamente');
    } catch (e) {
      // El repositoryImpl lanza mensaje claro si ya la tiene
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // REVOCAR DE USUARIO — solo admin
  // =========================
  Future<void> revocarInsignia({
    required int insigniaId,
    required String userId,
  }) async {
    final adminId = _userId;
    if (adminId == null) {
      Get.snackbar('Error', 'Debes iniciar sesión');
      return;
    }

    try {
      isSubmitting.value = true;

      await repository.revocarInsignia(insigniaId: insigniaId, userId: userId);

      // Remover de la lista local sin recargar
      usuariosDeInsignia.removeWhere(
        (u) => u.idInsignia == insigniaId && u.idUsuario == userId,
      );

      Get.snackbar('Éxito', 'Insignia revocada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo revocar la insignia');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // FILTRAR POR TIPO — sin llamada a API
  // =========================
  Future<void> aplicarFiltro(String? tipo) async {
    await loadInsignias(tipo: tipo);
  }
}
