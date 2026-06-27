import '../../domain/repositories/insignias_repository.dart';
import '../datasources/insignias_remote_datasource.dart';
import '../models/insignias_model.dart';

class InsigniaRepositoryImpl implements InsigniaRepository {
  final InsigniaRemoteDatasource remoteDatasource;

  InsigniaRepositoryImpl({required this.remoteDatasource});

  // =========================
  // GET TODAS
  // =========================
  @override
  Future<List<InsigniaModel>> getInsignias({String? tipoFiltro}) async {
    final response =
        await remoteDatasource.getInsignias(tipoFiltro: tipoFiltro);
    return response.map((e) => InsigniaModel.fromJson(e)).toList();
  }

  // =========================
  // GET BY ID
  // =========================
  @override
  Future<InsigniaModel?> getInsigniaById(int id) async {
    final response = await remoteDatasource.getInsigniaById(id);
    if (response == null) return null;
    return InsigniaModel.fromJson(response);
  }

  // =========================
  // GET INSIGNIAS DE USUARIO
  // =========================
  @override
  Future<List<InsigniaModel>> getInsigniasDeUsuario(String userId) async {
    final response =
        await remoteDatasource.getInsigniasDeUsuario(userId);
    return response.map((e) => InsigniaModel.fromJson(e)).toList();
  }

  // =========================
  // GET USUARIOS DE INSIGNIA
  // =========================
  @override
  Future<List<UsuarioInsigniaModel>> getUsuariosDeInsignia(
    int insigniaId,
  ) async {
    final response =
        await remoteDatasource.getUsuariosDeInsignia(insigniaId);
    return response
        .map((e) => UsuarioInsigniaModel.fromJson(e))
        .toList();
  }

  // =========================
  // VERIFICAR SI USUARIO TIENE INSIGNIA
  // =========================
  @override
  Future<bool> usuarioTieneInsignia({
    required int insigniaId,
    required String userId,
  }) async {
    return await remoteDatasource.usuarioTieneInsignia(
      insigniaId: insigniaId,
      userId: userId,
    );
  }

  // =========================
  // CREATE — solo admin
  // =========================
  @override
  Future<void> createInsignia(Map<String, dynamic> data) async {
    await remoteDatasource.createInsignia(data);
  }

  // =========================
  // UPDATE — solo admin
  // =========================
  @override
  Future<void> updateInsignia({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    await remoteDatasource.updateInsignia(id: id, data: data);
  }

  // =========================
  // DELETE — solo admin
  // =========================
  @override
  Future<void> deleteInsignia(int id) async {
    await remoteDatasource.deleteInsignia(id);
  }

  // =========================
  // ASIGNAR — solo admin
  // Verifica duplicado antes de insertar
  // =========================
  @override
  Future<void> asignarInsignia({
    required int insigniaId,
    required String userId,
  }) async {
    final yaTiene = await remoteDatasource.usuarioTieneInsignia(
      insigniaId: insigniaId,
      userId: userId,
    );
    if (yaTiene) throw Exception('El usuario ya tiene esta insignia');
    await remoteDatasource.asignarInsignia(
      insigniaId: insigniaId,
      userId: userId,
    );
  }

  // =========================
  // REVOCAR — solo admin
  // =========================
  @override
  Future<void> revocarInsignia({
    required int insigniaId,
    required String userId,
  }) async {
    await remoteDatasource.revocarInsignia(
      insigniaId: insigniaId,
      userId: userId,
    );
  }
}