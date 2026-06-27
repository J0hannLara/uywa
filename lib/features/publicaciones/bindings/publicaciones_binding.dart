import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/publicaciones_remote_datasource.dart';
import '../data/datasources/publicaciones_local_datasource.dart';
import '../data/repositories/publicaciones_repository_impl.dart';
import 'package:mypets/core/services/storage_service.dart';
import 'package:mypets/core/services/image_service.dart';
import '../presentation/controllers/publicaciones_controller.dart';

class PublicacionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PublicacionRemoteDatasource>(
      () => PublicacionRemoteDatasource(Supabase.instance.client),
    );

    Get.lazyPut<PublicacionLocalDatasource>(
      () => PublicacionLocalDatasource(),
    );

    Get.lazyPut<PublicacionRepositoryImpl>(
      () => PublicacionRepositoryImpl(
        remoteDatasource: Get.find<PublicacionRemoteDatasource>(),
        localDatasource: Get.find<PublicacionLocalDatasource>(),
        storageService: Get.find<StorageService>(),
        imageService: Get.find<ImageService>(),
      ),
    );

    Get.lazyPut<PublicacionController>(
      () => PublicacionController(
        repository: Get.find<PublicacionRepositoryImpl>(),
      ),
    );
  }
}