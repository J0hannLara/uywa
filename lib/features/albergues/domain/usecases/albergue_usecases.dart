// lib/features/albergues/domain/usecases/albergue_usecases.dart
import '../repositories/albergues_repository.dart';
import '../../data/models/albergues_model.dart';

// ============================================
// GET ALBERGUES PUBLICOS
// ============================================
class GetAlberguesPublicos {
  final AlbergueRepository repository;

  GetAlberguesPublicos(this.repository);

  Future<List<AlbergueModel>> call({
    int limite = 20,
    int offset = 0,
  }) async {
    return await repository.getAlberguesPublicos(
      limite: limite,
      offset: offset,
    );
  }
}

// ============================================
// GET MIS ALBERGUES
// ============================================
class GetMisAlbergues {
  final AlbergueRepository repository;

  GetMisAlbergues(this.repository);

  Future<List<AlbergueModel>> call(String userId) async {
    return await repository.getMisAlbergues(userId);
  }
}

// ============================================
// GET ALBERGUE BY ID
// ============================================
class GetAlbergueById {
  final AlbergueRepository repository;

  GetAlbergueById(this.repository);

  Future<AlbergueModel?> call(int id) async {
    return await repository.getAlbergueById(id);
  }
}

// ============================================
// UPDATE ALBERGUE
// ============================================
class UpdateAlbergue {
  final AlbergueRepository repository;

  UpdateAlbergue(this.repository);

  Future<void> call({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    await repository.updateAlbergue(id: id, data: data);
  }
}

// ============================================
// AGREGAR MIEMBRO
// ============================================
class AgregarMiembro {
  final AlbergueRepository repository;

  AgregarMiembro(this.repository);

  Future<void> call({
    required int albergueId,
    required String userId,
    required String rol,
  }) async {
    await repository.agregarMiembro(
      albergueId: albergueId,
      userId: userId,
      rol: rol,
    );
  }
}

// ============================================
// ACTUALIZAR ROL DE MIEMBRO
// ============================================
class ActualizarRolMiembro {
  final AlbergueRepository repository;

  ActualizarRolMiembro(this.repository);

  Future<void> call({
    required int albergueId,
    required String userId,
    required String nuevoRol,
  }) async {
    await repository.actualizarRolMiembro(
      albergueId: albergueId,
      userId: userId,
      nuevoRol: nuevoRol,
    );
  }
}

// ============================================
// REMOVER MIEMBRO
// ============================================
class RemoverMiembro {
  final AlbergueRepository repository;

  RemoverMiembro(this.repository);

  Future<void> call({
    required int albergueId,
    required String userId,
  }) async {
    await repository.removerMiembro(
      albergueId: albergueId,
      userId: userId,
    );
  }
}

// ============================================
// INGRESAR MASCOTA
// ============================================
class IngresarMascota {
  final AlbergueRepository repository;

  IngresarMascota(this.repository);

  Future<void> call({
    required int mascotaId,
    required int albergueId,
  }) async {
    await repository.ingresarMascota(
      mascotaId: mascotaId,
      albergueId: albergueId,
    );
  }
}

// ============================================
// ACTUALIZAR ESTADO DE MASCOTA
// ============================================
class ActualizarEstadoMascota {
  final AlbergueRepository repository;

  ActualizarEstadoMascota(this.repository);

  Future<void> call({
    required int mascotaAlbergueId,
    required String nuevoEstado,
    DateTime? fechaSalida,
  }) async {
    await repository.actualizarEstadoMascota(
      mascotaAlbergueId: mascotaAlbergueId,
      nuevoEstado: nuevoEstado,
      fechaSalida: fechaSalida,
    );
  }
}

// ============================================
// GET MASCOTAS DE ALBERGUE
// ============================================
class GetMascotasDeAlbergue {
  final AlbergueRepository repository;

  GetMascotasDeAlbergue(this.repository);

  Future<List<Map<String, dynamic>>> call(int albergueId) async {
    return await repository.getMascotasDeAlbergue(albergueId);
  }
}