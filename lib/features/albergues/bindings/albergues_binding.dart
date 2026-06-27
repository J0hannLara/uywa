// lib/features/albergues/presentation/bindings/albergue_binding.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/albergues_remote_datasource.dart';
import '../data/repositories/albergues_repository_impl.dart';
import '../domain/repositories/albergues_repository.dart';
import '../domain/usecases/albergue_usecases.dart'; // 👈 UN SOLO ARCHIVO
import '../presentation/controllers/albergues_controller.dart';

class AlbergueBinding extends Bindings {
  @override
  void dependencies() {
    // Remote Datasource
    Get.lazyPut<AlbergueRemoteDatasource>(
      () => AlbergueRemoteDatasource(Supabase.instance.client),
    );

    // Repository
    Get.lazyPut<AlbergueRepository>(
      () => AlbergueRepositoryImpl(Get.find<AlbergueRemoteDatasource>()),
    );

    // Use Cases
    Get.lazyPut<GetAlberguesPublicos>(
      () => GetAlberguesPublicos(Get.find<AlbergueRepository>()),
    );
    
    Get.lazyPut<GetMisAlbergues>(
      () => GetMisAlbergues(Get.find<AlbergueRepository>()),
    );
    
    Get.lazyPut<GetAlbergueById>(
      () => GetAlbergueById(Get.find<AlbergueRepository>()),
    );
    
    Get.lazyPut<UpdateAlbergue>(
      () => UpdateAlbergue(Get.find<AlbergueRepository>()),
    );
    
    Get.lazyPut<AgregarMiembro>(
      () => AgregarMiembro(Get.find<AlbergueRepository>()),
    );
    
    Get.lazyPut<ActualizarRolMiembro>(
      () => ActualizarRolMiembro(Get.find<AlbergueRepository>()),
    );
    
    Get.lazyPut<RemoverMiembro>(
      () => RemoverMiembro(Get.find<AlbergueRepository>()),
    );
    
    Get.lazyPut<IngresarMascota>(
      () => IngresarMascota(Get.find<AlbergueRepository>()),
    );
    
    Get.lazyPut<ActualizarEstadoMascota>(
      () => ActualizarEstadoMascota(Get.find<AlbergueRepository>()),
    );
    
    Get.lazyPut<GetMascotasDeAlbergue>(
      () => GetMascotasDeAlbergue(Get.find<AlbergueRepository>()),
    );

    // Controller
    Get.lazyPut<AlbergueController>(
      () => AlbergueController(
        getAlberguesPublicos: Get.find<GetAlberguesPublicos>(),
        getMisAlbergues: Get.find<GetMisAlbergues>(),
        getAlbergueById: Get.find<GetAlbergueById>(),
        updateAlbergue: Get.find<UpdateAlbergue>(),
        agregarMiembro: Get.find<AgregarMiembro>(),
        actualizarRolMiembro: Get.find<ActualizarRolMiembro>(),
        removerMiembro: Get.find<RemoverMiembro>(),
        ingresarMascota: Get.find<IngresarMascota>(),
        actualizarEstadoMascota: Get.find<ActualizarEstadoMascota>(),
        getMascotasDeAlbergue: Get.find<GetMascotasDeAlbergue>(),
      ),
    );
  }
}