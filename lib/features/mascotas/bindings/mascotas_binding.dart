import 'package:get/get.dart';
import 'package:mypets/core/services/image_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/mascotas_remote_datasource.dart';
import '../data/datasources/mascotas_local_datasource.dart';
import '../data/repositories/mascotas_repository_impl.dart';
import 'package:mypets/core/services/storage_service.dart';
import '../presentation/controllers/mascotas_controller.dart';

class MascotaBinding extends Bindings {
  @override
  void dependencies() {
    // Datasources
    Get.lazyPut<MascotaRemoteDatasource>(
      () => MascotaRemoteDatasource(Supabase.instance.client),
    );

    Get.lazyPut<MascotaLocalDatasource>(
      () => MascotaLocalDatasource(),
    );


    // Repository
    Get.lazyPut<MascotaRepositoryImpl>(
      () => MascotaRepositoryImpl(
        remoteDatasource: Get.find<MascotaRemoteDatasource>(),
        localDatasource: Get.find<MascotaLocalDatasource>(),
        storageService: Get.find<StorageService>(),
        imageService: Get.find<ImageService>(),
      ),
    );

    // Controller
    Get.lazyPut<MascotaController>(
      () => MascotaController(
        repository: Get.find<MascotaRepositoryImpl>(),
      ),
    );
  }
}