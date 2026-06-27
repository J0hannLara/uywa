import '../../data/models/perdidas_model.dart';

abstract class PerdidaRepository {
  Future<List<PerdidaModel>> getPerdidas({
    String? estadoFiltro,
    int limite,
    int offset,
  });

  Future<List<PerdidaModel>> getPerdidasPorMascota(int mascotaId);

  Future<PerdidaModel?> getPerdidaById(int id);

  Future<void> createPerdida({
    required int idMascota,
    required DateTime fechaPerdida,
    required String lugarPerdida,
    String? descripcionPerdida,
    double? latitud,
    double? longitud,
    int radioBusquedaKm,
    double? recompensa,
  });

  Future<void> updatePerdida({
    required int id,
    required Map<String, dynamic> data,
  });

  Future<void> marcarComoEncontrada({
    required int id,
    String? detalles,
  });

  Future<void> deletePerdida(int id);
}