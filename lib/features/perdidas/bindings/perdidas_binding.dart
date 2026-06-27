import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/perdidas_remote_datasource.dart';
import '../data/repositories/perdidas_repository_impl.dart';
import '../presentation/controllers/perdidas_controller.dart';

class PerdidaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PerdidaRemoteDatasource>(
      () => PerdidaRemoteDatasource(Supabase.instance.client),
    );

    Get.lazyPut<PerdidaRepositoryImpl>(
      () => PerdidaRepositoryImpl(
        remoteDatasource: Get.find<PerdidaRemoteDatasource>(),
      ),
    );

    Get.lazyPut<PerdidaController>(
      () => PerdidaController(
        repository: Get.find<PerdidaRepositoryImpl>(),
      ),
    );
  }
}