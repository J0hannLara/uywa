// lib/features/albergues/data/repositories/albergue_repository_impl.dart
import '../../domain/repositories/albergues_repository.dart';
import '../datasources/albergues_remote_datasource.dart';
import '../models/albergues_model.dart';

class AlbergueRepositoryImpl implements AlbergueRepository {
  final AlbergueRemoteDatasource remoteDatasource;

  AlbergueRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<AlbergueModel>> getAlberguesPublicos({
    int limite = 20,
    int offset = 0,
  }) async {
    try {
      final response = await remoteDatasource.getAlberguesPublicos(
        limite: limite,
        offset: offset,
      );
      return response.map((json) => AlbergueModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar albergues públicos: $e');
    }
  }

  @override
  Future<List<AlbergueModel>> getMisAlbergues(String userId) async {
    try {
      final response = await remoteDatasource.getMisAlbergues(userId);
      return response.map((json) => AlbergueModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar tus albergues: $e');
    }
  }

  @override
  Future<AlbergueModel?> getAlbergueById(int id) async {
    try {
      final response = await remoteDatasource.getAlbergueById(id);
      if (response == null) return null;
      return AlbergueModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al cargar el albergue: $e');
    }
  }

  @override
  Future<void> updateAlbergue({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await remoteDatasource.updateAlbergue(id: id, data: data);
    } catch (e) {
      throw Exception('Error al actualizar el albergue: $e');
    }
  }

  @override
  Future<void> agregarMiembro({
    required int albergueId,
    required String userId,
    required String rol,
  }) async {
    try {
      await remoteDatasource.agregarMiembro(
        albergueId: albergueId,
        userId: userId,
        rol: rol,
      );
    } catch (e) {
      throw Exception('Error al agregar miembro: $e');
    }
  }

  @override
  Future<void> actualizarRolMiembro({
    required int albergueId,
    required String userId,
    required String nuevoRol,
  }) async {
    try {
      await remoteDatasource.actualizarRolMiembro(
        albergueId: albergueId,
        userId: userId,
        nuevoRol: nuevoRol,
      );
    } catch (e) {
      throw Exception('Error al actualizar rol: $e');
    }
  }

  @override
  Future<void> removerMiembro({
    required int albergueId,
    required String userId,
  }) async {
    try {
      await remoteDatasource.removerMiembro(
        albergueId: albergueId,
        userId: userId,
      );
    } catch (e) {
      throw Exception('Error al remover miembro: $e');
    }
  }

  @override
  Future<void> ingresarMascota({
    required int mascotaId,
    required int albergueId,
  }) async {
    try {
      await remoteDatasource.ingresarMascota(
        mascotaId: mascotaId,
        albergueId: albergueId,
      );
    } catch (e) {
      throw Exception('Error al ingresar mascota: $e');
    }
  }

  @override
  Future<void> actualizarEstadoMascota({
    required int mascotaAlbergueId,
    required String nuevoEstado,
    DateTime? fechaSalida,
  }) async {
    try {
      await remoteDatasource.actualizarEstadoMascota(
        mascotaAlbergueId: mascotaAlbergueId,
        nuevoEstado: nuevoEstado,
        fechaSalida: fechaSalida,
      );
    } catch (e) {
      throw Exception('Error al actualizar estado de mascota: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMascotasDeAlbergue(
      int albergueId) async {
    try {
      return await remoteDatasource.getMascotasDeAlbergue(albergueId);
    } catch (e) {
      throw Exception('Error al cargar mascotas del albergue: $e');
    }
  }
}