import 'dart:io';
import '../../domain/repositories/publicaciones_repository.dart';
import '../datasources/publicaciones_remote_datasource.dart';
import '../datasources/publicaciones_local_datasource.dart';
import '../models/publicaciones_model.dart';
import 'package:mypets/core/services/storage_service.dart';
import 'package:mypets/core/services/image_service.dart';

class PublicacionRepositoryImpl implements PublicacionRepository {
  final PublicacionRemoteDatasource remoteDatasource;
  final PublicacionLocalDatasource localDatasource;
  final StorageService storageService;
  final ImageService imageService;

  PublicacionRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.storageService,
    required this.imageService,
  });

  // =========================
  // FEED GLOBAL
  // =========================
  @override
  Future<List<PublicacionModel>> getFeedGlobal({
    int limite = 20,
    int offset = 0,
    String? tipoFiltro,
  }) async {
    if (offset == 0 && tipoFiltro == null) {
      final cached = localDatasource.getFeedGlobal();
      if (cached != null) {
        return cached.map((e) => PublicacionModel.fromJson(e)).toList();
      }
    }

    final response = await remoteDatasource.getFeedGlobal(
      limite: limite,
      offset: offset,
      tipofiltro: tipoFiltro,
    );

    final publicaciones =
        response.map((e) => PublicacionModel.fromJson(e)).toList();

    if (offset == 0 && tipoFiltro == null) {
      await localDatasource.saveFeedGlobal(response);
    }

    return publicaciones;
  }

  // =========================
  // MIS PUBLICACIONES
  // =========================
  @override
  Future<List<PublicacionModel>> getMisPublicaciones(
    String userId, {
    int limite = 20,
    int offset = 0,
  }) async {
    if (offset == 0) {
      final cached = localDatasource.getMisPublicaciones();
      if (cached != null) {
        return cached.map((e) => PublicacionModel.fromJson(e)).toList();
      }
    }

    final response = await remoteDatasource.getMisPublicaciones(
      userId,
      limite: limite,
      offset: offset,
    );

    final publicaciones =
        response.map((e) => PublicacionModel.fromJson(e)).toList();

    if (offset == 0) {
      await localDatasource.saveMisPublicaciones(response);
    }

    return publicaciones;
  }

  // =========================
  // GET BY ID
  // =========================
  @override
  Future<PublicacionModel?> getPublicacionById(int id) async {
    final response = await remoteDatasource.getPublicacionById(id);
    if (response == null) return null;
    return PublicacionModel.fromJson(response);
  }

  // =========================
  // CREATE
  // =========================
  @override
  Future<void> createPublicacion({
    required Map<String, dynamic> data,
    required String userId,
    int? idMascota,
    List<File> imagenes = const [],
  }) async {
    final publicacionId = await remoteDatasource.createPublicacion({
      ...data,
      'id_usuario': userId,
      if (idMascota != null) 'id_mascota': idMascota,
    });

    if (imagenes.isNotEmpty) {
      final urls = await _subirImagenes(
        imagenes: imagenes,
        userId: userId,
        publicacionId: publicacionId,
      );
      if (urls.isNotEmpty) {
        await remoteDatasource.insertImagenes(publicacionId, urls);
      }
    }

    await localDatasource.clearAll();
  }

  // =========================
  // UPDATE
  // =========================
  @override
  Future<void> updatePublicacion({
    required int id,
    required Map<String, dynamic> data,
    List<File> nuevasImagenes = const [],
    required String userId,
  }) async {
    await remoteDatasource.updatePublicacion(id: id, data: data);

    if (nuevasImagenes.isNotEmpty) {
      final urls = await _subirImagenes(
        imagenes: nuevasImagenes,
        userId: userId,
        publicacionId: id,
      );
      if (urls.isNotEmpty) {
        await remoteDatasource.reemplazarImagenes(id, urls);
      }
    }

    await localDatasource.clearAll();
  }

  // =========================
  // DELETE
  // =========================
  @override
  Future<void> deletePublicacion(int id) async {
    await remoteDatasource.deletePublicacion(id);
    await localDatasource.clearAll();
  }

  // =========================
  // VISUALIZACIONES
  // =========================
  @override
  Future<void> incrementarVisualizacion(int id) async {
    await remoteDatasource.incrementarVisualizacion(id);
  }

  // =========================
  // CLEAR CACHE
  // =========================
  @override
  Future<void> clearCache() async {
    await localDatasource.clearAll();
  }

  // =========================
  // HELPER — convierte a webp y sube
  // Filtra nulls: si una imagen falla no rompe el resto
  // =========================
  Future<List<String>> _subirImagenes({
    required List<File> imagenes,
    required String userId,
    required int publicacionId,
  }) async {
    final futures = imagenes.asMap().entries.map((entry) async {
      final index = entry.key;
      final file = entry.value;

      // Convertir a webp antes de subir
      final webpFile = await imageService.convertToWebp(file);
      if (webpFile == null) return null;

      return storageService.uploadImage(
        file: webpFile,
        bucket: 'publicaciones',
        path:
            '$userId/$publicacionId/${index}_${DateTime.now().millisecondsSinceEpoch}.webp',
      );
    });

    final results = await Future.wait(futures);

    // Filtrar nulls — String? → String
    return results.whereType<String>().toList();
  }
}