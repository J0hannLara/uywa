import 'dart:io';
import '../../data/models/publicaciones_model.dart';

abstract class PublicacionRepository {
  // Feed global paginado con filtro opcional por tipo
  Future<List<PublicacionModel>> getFeedGlobal({
    int limite,
    int offset,
    String? tipoFiltro,
  });

  // Publicaciones del usuario autenticado
  Future<List<PublicacionModel>> getMisPublicaciones(
    String userId, {
    int limite,
    int offset,
  });

  Future<PublicacionModel?> getPublicacionById(int id);

  Future<void> createPublicacion({
    required Map<String, dynamic> data,
    required String userId,
    int? idMascota,
    List<File> imagenes,
  });

  Future<void> updatePublicacion({
    required int id,
    required Map<String, dynamic> data,
    List<File> nuevasImagenes,
    required String userId,
  });

  Future<void> deletePublicacion(int id);

  Future<void> incrementarVisualizacion(int id);

  Future<void> clearCache();
}