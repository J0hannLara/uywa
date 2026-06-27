// lib/features/albergues/domain/repositories/albergue_repository.dart
import '../../data/models/albergues_model.dart';

abstract class AlbergueRepository {
  // Obtener albergues públicos (verificados y activos)
  Future<List<AlbergueModel>> getAlberguesPublicos({
    int limite = 20,
    int offset = 0,
  });

  // Obtener albergues donde el usuario es miembro
  Future<List<AlbergueModel>> getMisAlbergues(String userId);

  // Obtener albergue por ID
  Future<AlbergueModel?> getAlbergueById(int id);

  // Actualizar información del albergue
  Future<void> updateAlbergue({
    required int id,
    required Map<String, dynamic> data,
  });

  // Agregar miembro al albergue
  Future<void> agregarMiembro({
    required int albergueId,
    required String userId,
    required String rol,
  });

  // Actualizar rol de miembro
  Future<void> actualizarRolMiembro({
    required int albergueId,
    required String userId,
    required String nuevoRol,
  });

  // Remover miembro del albergue
  Future<void> removerMiembro({
    required int albergueId,
    required String userId,
  });

  // Ingresar mascota al albergue
  Future<void> ingresarMascota({
    required int mascotaId,
    required int albergueId,
  });

  // Actualizar estado de mascota en albergue
  Future<void> actualizarEstadoMascota({
    required int mascotaAlbergueId,
    required String nuevoEstado,
    DateTime? fechaSalida,
  });

  // Obtener mascotas activas de un albergue
  Future<List<Map<String, dynamic>>> getMascotasDeAlbergue(int albergueId);
}