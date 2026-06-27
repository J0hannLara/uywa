import 'package:get/get.dart';
import '../../domain/repositories/evento_repository.dart';
import '../../data/models/evento_model.dart';
import '../../../../core/services/session_controller.dart';

class EventoController extends GetxController {
  final EventoRepository repository;
  final SessionController sessionController = Get.find<SessionController>();

  EventoController({required this.repository});

  // =========================
  // ESTADO REACTIVO
  // =========================
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // Listas
  final RxList<EventoModel> eventosActivos = <EventoModel>[].obs;
  final RxList<EventoModel> misEventos = <EventoModel>[].obs;
  final RxList<EventoModel> eventosAdmin = <EventoModel>[].obs;
  final Rxn<EventoModel> selectedEvento = Rxn<EventoModel>();

  // Participantes
  final RxList<Map<String, dynamic>> participantes =
      <Map<String, dynamic>>[].obs;

  // Paginación
  final RxInt offsetActivos = 0.obs;
  final RxBool hayMasActivos = true.obs;
  final RxInt offsetAdmin = 0.obs;
  final RxBool hayMasAdmin = true.obs;
  static const int _limite = 20;

  String? get _userId => sessionController.currentUser.value?.id;

  @override
  void onInit() {
    super.onInit();
    loadEventosActivos();
  }

  // =========================
  // LOAD EVENTOS ACTIVOS
  // =========================
  Future<void> loadEventosActivos({bool reiniciar = false}) async {
    final userId = _userId;
    if (userId == null) return;

    if (reiniciar) {
      offsetActivos.value = 0;
      hayMasActivos.value = true;
      eventosActivos.clear();
    }

    if (!hayMasActivos.value) return;

    try {
      isLoading.value = true;
      final result = await repository.getEventosActivos(
        userId: userId,
        limite: _limite,
        offset: offsetActivos.value,
      );

      eventosActivos.addAll(result);
      offsetActivos.value += result.length;

      if (result.length < _limite) {
        hayMasActivos.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los eventos');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cargarMasActivos() async {
    if (!isLoading.value && hayMasActivos.value) {
      await loadEventosActivos();
    }
  }

  Future<void> refreshEventosActivos() async {
    await loadEventosActivos(reiniciar: true);
  }

  // =========================
  // LOAD MIS EVENTOS
  // =========================
  Future<void> loadMisEventos() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final result = await repository.getMisEventos(userId);
      misEventos.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar tus eventos');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMisEventos() async {
    await loadMisEventos();
  }

  // =========================
  // LOAD EVENTOS ADMIN
  // =========================
  Future<void> loadEventosAdmin({bool reiniciar = false}) async {
    print('🎯 [Controller] loadEventosAdmin - Iniciando');
    print('🎯 [Controller] reiniciar: $reiniciar');
    print('🎯 [Controller] offsetAdmin actual: ${offsetAdmin.value}');
    print('🎯 [Controller] hayMasAdmin actual: ${hayMasAdmin.value}');

    if (reiniciar) {
      print('🎯 [Controller] Reiniciando offset y limpiando lista');
      offsetAdmin.value = 0;
      hayMasAdmin.value = true;
      eventosAdmin.clear();
      print('🎯 [Controller] offsetAdmin reiniciado: ${offsetAdmin.value}');
    }

    if (!hayMasAdmin.value) {
      print(
        '🎯 [Controller] No hay más eventos para cargar (hayMasAdmin=false)',
      );
      return;
    }

    try {
      print('🎯 [Controller] isLoading = true');
      isLoading.value = true;

      print('🎯 [Controller] Llamando a repository.getEventosAdmin...');
      final result = await repository.getEventosAdmin(
        limite: _limite,
        offset: offsetAdmin.value,
      );

      print('🎯 [Controller] Resultado recibido: ${result.length} eventos');

      if (result.isEmpty) {
        print('🎯 [Controller] ADVERTENCIA: El repositorio devolvió 0 eventos');
        print('🎯 [Controller] Verificar que la tabla tenga datos');
        print('🎯 [Controller] Verificar que las RLS policies permitan SELECT');
      }

      // Mostrar primeros 3 eventos para depuración
      if (result.isNotEmpty) {
        print('🎯 [Controller] Primeros 3 eventos:');
        result.take(3).forEach((evento) {
          print(
            '🎯 [Controller] - ID: ${evento.id}, Nombre: ${evento.nombre}, Tipo: ${evento.tipo}',
          );
        });
      }

      eventosAdmin.addAll(result);
      print(
        '🎯 [Controller] eventosAdmin ahora tiene: ${eventosAdmin.length} eventos',
      );

      offsetAdmin.value += result.length;
      print('🎯 [Controller] offsetAdmin actualizado: ${offsetAdmin.value}');

      if (result.length < _limite) {
        hayMasAdmin.value = false;
        print(
          '🎯 [Controller] hayMasAdmin = false (result.length ${result.length} < _limite $_limite)',
        );
      }

      print('🎯 [Controller] loadEventosAdmin COMPLETADO EXITOSAMENTE');
    } catch (e) {
      print('❌ [Controller] ERROR en loadEventosAdmin: $e');
      print('❌ [Controller] Stacktrace: ${StackTrace.current}');
      print('❌ [Controller] Tipo de error: ${e.runtimeType}');

      Get.snackbar(
        'Error',
        'No se pudieron cargar los eventos: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      print('🎯 [Controller] isLoading = false');
      isLoading.value = false;
      print('🎯 [Controller] FINALIZADO loadEventosAdmin');
    }
  }

  Future<void> cargarMasAdmin() async {
    if (!isLoading.value && hayMasAdmin.value) {
      await loadEventosAdmin();
    }
  }

  Future<void> refreshEventosAdmin() async {
    await loadEventosAdmin(reiniciar: true);
  }

  // =========================
  // SELECT EVENTO
  // =========================
  Future<void> selectEvento(int id) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final evento = await repository.getEventoById(id: id, userId: userId);
      if (evento != null) {
        selectedEvento.value = evento;
        await loadParticipantes(evento.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el evento');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSelected() {
    selectedEvento.value = null;
    participantes.clear();
  }

  // =========================
  // LOAD PARTICIPANTES
  // =========================
  Future<void> loadParticipantes(int eventoId) async {
    try {
      final result = await repository.getParticipantesDeEvento(eventoId);
      participantes.assignAll(result);
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // CREATE EVENTO (Admin)
  // =========================
  Future<void> createEvento({
    required String nombre,
    required String tipo,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? descripcion,
    int? idInsignia,
    int? limiteReclamos,
    String? imagenUrl,
    bool activo = true,
  }) async {
    final userId = _userId;
    if (userId == null) {
      Get.snackbar('Error', 'Debes iniciar sesión');
      return;
    }

    try {
      isSubmitting.value = true;

      final data = {
        'nombre': nombre,
        'tipo': tipo,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        'activo': activo,
        if (descripcion != null) 'descripcion': descripcion,
        if (idInsignia != null) 'id_insignia': idInsignia,
        if (limiteReclamos != null) 'limite_reclamos': limiteReclamos,
        if (imagenUrl != null) 'imagen_url': imagenUrl,
      };

      await repository.createEvento(data);
      await refreshEventosAdmin();
      await refreshEventosActivos();

      Get.snackbar('Éxito', 'Evento creado correctamente');
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear el evento');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // UPDATE EVENTO (Admin)
  // =========================
  Future<void> updateEvento({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      isSubmitting.value = true;
      await repository.updateEvento(id: id, data: data);
      await refreshEventosAdmin();
      await refreshEventosActivos();

      if (selectedEvento.value?.id == id) {
        await selectEvento(id);
      }

      Get.snackbar('Éxito', 'Evento actualizado correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el evento');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // DELETE EVENTO (Admin)
  // =========================
  Future<void> deleteEvento(int id) async {
    try {
      isSubmitting.value = true;
      await repository.deleteEvento(id);

      eventosAdmin.removeWhere((e) => e.id == id);
      eventosActivos.removeWhere((e) => e.id == id);

      if (selectedEvento.value?.id == id) {
        clearSelected();
      }

      Get.snackbar('Éxito', 'Evento eliminado correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar el evento');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // VERIFICAR SI USUARIO PARTICIPA EN EVENTO
  // =========================
  Future<bool> usuarioParticipaEnEvento(int eventoId, String userId) async {
    try {
      final misEventos = await repository.getMisEventos(userId);
      return misEventos.any((e) => e.id == eventoId);
    } catch (e) {
      print('Error verificando participación: $e');
      return false;
    }
  }

  // =========================
  // VERIFICAR SI USUARIO RECLAMO EVENTO
  // =========================
  Future<bool> usuarioReclamoEvento(int eventoId, String userId) async {
    try {
      final misEventos = await repository.getMisEventos(userId);
      final evento = misEventos.firstWhereOrNull((e) => e.id == eventoId);
      return evento?.usuarioReclamo ?? false;
    } catch (e) {
      print('Error verificando reclamo: $e');
      return false;
    }
  }

  // =========================
  // UNIRSE A EVENTO
  // =========================
  Future<void> unirseEvento(int eventoId) async {
    final userId = _userId;
    if (userId == null) {
      Get.snackbar('Error', 'Debes iniciar sesión');
      return;
    }

    try {
      isSubmitting.value = true;
      await repository.unirseEvento(eventoId: eventoId, userId: userId);

      await refreshEventosActivos();
      await refreshMisEventos();

      if (selectedEvento.value?.id == eventoId) {
        await selectEvento(eventoId);
      }

      Get.snackbar('Éxito', 'Te has unido al evento');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo unir al evento');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // RECLAMAR INSIGNIA
  // =========================
  Future<void> reclamarInsignia(int eventoId) async {
    final userId = _userId;
    print('reclamando insignia');
    if (userId == null) {
      Get.snackbar('Error', 'Debes iniciar sesión');
      return;
    }

    try {
      isSubmitting.value = true;
      await repository.reclamarInsignia(eventoId: eventoId, userId: userId);

      await refreshEventosActivos();
      await refreshMisEventos();

      if (selectedEvento.value?.id == eventoId) {
        await selectEvento(eventoId);
      }

      Get.snackbar('Éxito', '¡Insignia reclamada correctamente!');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo reclamar la insignia');
    } finally {
      isSubmitting.value = false;
    }
  }

  // =========================
  // HELPERS
  // =========================
  bool estaParticipando(int eventoId) {
    return eventosActivos.any((e) => e.id == eventoId && e.usuarioParticipa);
  }

  bool yaReclamo(int eventoId) {
    return eventosActivos.any((e) => e.id == eventoId && e.usuarioReclamo);
  }
}
