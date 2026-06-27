import '../../domain/repositories/mascotas_repository.dart';
import '../datasources/mascotas_remote_datasource.dart';
import '../models/mascotas_model.dart';
import 'dart:io';
import '../datasources/mascotas_local_datasource.dart';
import 'package:mypets/core/services/storage_service.dart';
import 'package:mypets/core/services/image_service.dart';

class MascotaRepositoryImpl implements MascotaRepository {
  final MascotaRemoteDatasource remoteDatasource;
  final MascotaLocalDatasource localDatasource;
  final StorageService storageService;
  final ImageService imageService;

  MascotaRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.storageService,
    required this.imageService,
  });

  // =========================
  // GET MASCOTAS
  // =========================
  @override
  Future<List<MascotaModel>> getMascotas(String userId) async {
    final cached = localDatasource.getMascotas();
    if (cached != null) {
      return cached.map((e) => MascotaModel.fromJson(e)).toList();
    }

    final response = await remoteDatasource.getMascotas(userId);
    final mascotas = response.map((e) => MascotaModel.fromJson(e)).toList();

    await localDatasource.saveMascotas(response);
    return mascotas;
  }

  // =========================
  // GET BY ID
  // =========================
  @override
  Future<MascotaModel?> getMascotaById(int id) async {
    final response = await remoteDatasource.getMascotaById(id);
    if (response == null) return null;
    return MascotaModel.fromJson(response);
  }

  // =========================
  // CREATE
  // 1. Sube imagen (si existe)
  // 2. Inserta en mascotas → obtiene id
  // 3. Inserta en mascota_usuarios con estado activo
  // =========================
  @override
  Future<void> createMascota({
    required Map<String, dynamic> data,
    File? imagen,
    required String userId,
  }) async {
    String? imageUrl;

    if (imagen != null) {
      final webpFile = await imageService.convertToWebp(imagen);
      if (webpFile != null) {
        imageUrl = await storageService.uploadImage(
          file: webpFile,
          bucket: 'mascotas',
          path: '$userId/${DateTime.now().millisecondsSinceEpoch}.webp',
        );
      }
    }

    // Insert en mascotas — sin id_usuario
    final mascotaId = await remoteDatasource.createMascota({
      ...data,
      if (imageUrl != null) 'imagen_principal': imageUrl,
    });

    // Insert en mascota_usuarios — vincula al dueño
    await remoteDatasource.createMascotaUsuario(
      mascotaId: mascotaId,
      userId: userId,
      rol: 'dueno',
    );

    await localDatasource.clear();
  }

  // =========================
  // UPDATE
  // Solo actualiza mascotas, la relación no cambia
  // =========================
  @override
  Future<void> updateMascota({
    required int id,
    required Map<String, dynamic> data,
    File? nuevaImagen,
    required String userId,
  }) async {
    String? imageUrl;

    if (nuevaImagen != null) {
      final webpFile = await imageService.convertToWebp(nuevaImagen);
      if (webpFile != null) {
        imageUrl = await storageService.uploadImage(
          file: webpFile,
          bucket: 'mascotas',
          path: '$userId/${DateTime.now().millisecondsSinceEpoch}.webp',
        );
      }
    }

    await remoteDatasource.updateMascota(
      id: id,
      data: {
        ...data,
        if (imageUrl != null) 'imagen_principal': imageUrl,
      },
    );

    await localDatasource.clear();
  }

  // =========================
  // DELETE
  // CASCADE en BD elimina mascota_usuarios automáticamente
  // =========================
  @override
  Future<void> deleteMascota(int id) async {
    await remoteDatasource.deleteMascota(id);
    await localDatasource.clear();
  }

  // =========================
  // CLEAR CACHE
  // =========================
  @override
  Future<void> clearCache() async {
    await localDatasource.clear();
  }
}