import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mypets/features/perfiles/data/datasources/perfiles_remote_datasource.dart';
import 'package:mypets/features/perfiles/domain/repositories/profile_repository.dart';
import 'package:mypets/features/perfiles/data/repositories/perfiles_repository_impl.dart';
import 'package:mypets/features/perfiles/presentation/controllers/perfiles_controller.dart';
import '../services/session_controller.dart';
import '../services/storage_service.dart';
import 'package:mypets/features/mascotas/data/datasources/mascotas_remote_datasource.dart';
import 'package:mypets/features/mascotas/data/repositories/mascotas_repository_impl.dart';
import 'package:mypets/features/mascotas/domain/repositories/mascotas_repository.dart';
import 'package:mypets/features/mascotas/data/datasources/mascotas_local_datasource.dart';
import 'package:mypets/features/mascotas/presentation/controllers/mascotas_controller.dart';
import '../services/image_service.dart';
import 'package:mypets/features/auth/data/services/auth_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // CORE
    Get.put(SessionController(), permanent: true);

    Get.put(StorageService(), permanent: true);
    // DATASOURCES
    Get.put(ProfileRemoteDatasource(Supabase.instance.client), permanent: true);
    // REPOSITORIES
    Get.put<ProfileRepository>(
      ProfileRepositoryImpl(Get.find<ProfileRemoteDatasource>()),
      permanent: true,
    );
    //IMAGENES
    Get.put(ImageService(), permanent: true);
    // CONTROLLERS
    Get.put(ProfileController(), permanent: true);
    //AUTH SERVICE
    Get.put(AuthService(), permanent: true);

    // MASCOTAS

    Get.put(MascotaRemoteDatasource(Supabase.instance.client), permanent: true);

    Get.put(MascotaLocalDatasource(), permanent: true);

    Get.put(MascotaRemoteDatasource(Supabase.instance.client), permanent: true);

    Get.put<MascotaRepository>(
      MascotaRepositoryImpl(
        remoteDatasource: Get.find<MascotaRemoteDatasource>(),
        localDatasource: Get.find<MascotaLocalDatasource>(),
        storageService: Get.find<StorageService>(),
        imageService: Get.find<ImageService>(),
      ),
      permanent: true,
    );
    Get.put<MascotaController>(
      MascotaController(repository: Get.find<MascotaRepository>()),
      permanent: true,
    );
  }
}
