import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/insignias_remote_datasource.dart';
import '../data/repositories/insignias_repository_impl.dart';
import '../presentation/controllers/insignias_controller.dart';

class InsigniaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InsigniaRemoteDatasource>(
      () => InsigniaRemoteDatasource(Supabase.instance.client),
    );

    Get.lazyPut<InsigniaRepositoryImpl>(
      () => InsigniaRepositoryImpl(
        remoteDatasource: Get.find<InsigniaRemoteDatasource>(),
      ),
    );

    Get.lazyPut<InsigniaController>(
      () => InsigniaController(
        repository: Get.find<InsigniaRepositoryImpl>(),
      ),
    );
  }
}