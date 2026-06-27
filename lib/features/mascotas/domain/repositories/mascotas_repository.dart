import '../../data/models/mascotas_model.dart';
import 'dart:io';

abstract class MascotaRepository {
  Future<List<MascotaModel>> getMascotas(String userId);

  Future<MascotaModel?> getMascotaById(int id);

  Future<void> createMascota({
    required Map<String, dynamic> data,
    File? imagen,
    required String userId,
  });

  Future<void> updateMascota({
    required int id,
    required Map<String, dynamic> data,
    File? nuevaImagen,
    required String userId,
  });

  Future<void> deleteMascota(int id);

  Future<void> clearCache();
}