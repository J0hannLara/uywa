import '../../domain/repositories/perdidas_repository.dart';
import '../datasources/perdidas_remote_datasource.dart';
import '../models/perdidas_model.dart';

class PerdidaRepositoryImpl implements PerdidaRepository {
  final PerdidaRemoteDatasource remoteDatasource;

  PerdidaRepositoryImpl({required this.remoteDatasource});

  // =========================
  // GET TODAS
  // =========================
  @override
  Future<List<PerdidaModel>> getPerdidas({
    String? estadoFiltro,
    int limite = 20,
    int offset = 0,
  }) async {
    final response = await remoteDatasource.getPerdidas(
      estadoFiltro: estadoFiltro,
      limite: limite,
      offset: offset,
    );
    return response.map((e) => PerdidaModel.fromJson(e)).toList();
  }

  // =========================
  // GET POR MASCOTA
  // =========================
  @override
  Future<List<PerdidaModel>> getPerdidasPorMascota(int mascotaId) async {
    final response =
        await remoteDatasource.getPerdidasPorMascota(mascotaId);
    return response.map((e) => PerdidaModel.fromJson(e)).toList();
  }

  // =========================
  // GET BY ID
  // =========================
  @override
  Future<PerdidaModel?> getPerdidaById(int id) async {
    final response = await remoteDatasource.getPerdidaById(id);
    if (response == null) return null;
    return PerdidaModel.fromJson(response);
  }

  // =========================
  // CREATE
  // =========================
  @override
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
    await remoteDatasource.createPerdida({
      'id_mascota': idMascota,
      'fecha_perdida': fechaPerdida.toIso8601String(),
      'lugar_perdida': lugarPerdida,
      if (descripcionPerdida != null)
        'descripcion_perdida': descripcionPerdida,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      'radio_busqueda_km': radioBusquedaKm,
      if (recompensa != null) 'recompensa': recompensa,
    });
  }

  // =========================
  // UPDATE
  // =========================
  @override
  Future<void> updatePerdida({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    await remoteDatasource.updatePerdida(id: id, data: data);
  }

  // =========================
  // MARCAR COMO ENCONTRADA
  // =========================
  @override
  Future<void> marcarComoEncontrada({
    required int id,
    String? detalles,
  }) async {
    await remoteDatasource.marcarComoEncontrada(
      id: id,
      detalles: detalles,
    );
  }

  // =========================
  // DELETE
  // =========================
  @override
  Future<void> deletePerdida(int id) async {
    await remoteDatasource.deletePerdida(id);
  }
}