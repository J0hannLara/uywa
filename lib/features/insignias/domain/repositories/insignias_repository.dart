import '../../data/models/insignias_model.dart';

abstract class InsigniaRepository {
  // — Lectura pública
  Future<List<InsigniaModel>> getInsignias({String? tipoFiltro});
  Future<InsigniaModel?> getInsigniaById(int id);
  Future<List<InsigniaModel>> getInsigniasDeUsuario(String userId);
  Future<List<UsuarioInsigniaModel>> getUsuariosDeInsignia(int insigniaId);
  Future<bool> usuarioTieneInsignia({
    required int insigniaId,
    required String userId,
  });

  // — Solo admin
  Future<void> createInsignia(Map<String, dynamic> data);
  Future<void> updateInsignia({
    required int id,
    required Map<String, dynamic> data,
  });
  Future<void> deleteInsignia(int id);
  Future<void> asignarInsignia({
    required int insigniaId,
    required String userId,
  });
  Future<void> revocarInsignia({
    required int insigniaId,
    required String userId,
  });
}