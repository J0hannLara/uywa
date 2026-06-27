// lib/features/eventos/presentation/bindings/evento_binding.dart

import 'package:get/get.dart';
import '../domain/repositories/evento_repository.dart';
import '../data/repositories/evento_repository_impl.dart';
import '../data/datasources/evento_remote_datasource.dart';
import '../presentation/controllers/evento_controller.dart';
import 'package:mypets/core/cache/hive_cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventoBinding extends Bindings {
  @override
  void dependencies() {
    // Remote Datasource
    print('iniciando bindings de eventos');
    Get.lazyPut(
      () => EventoRemoteDatasource(
        Supabase.instance.client, 
      ),
    );

    // Repository
    Get.lazyPut<EventoRepository>(
      () => EventoRepositoryImpl(
        remoteDatasource: Get.find<EventoRemoteDatasource>(),
        cacheService: Get.find<HiveCacheService>(),
      ),
    );

    // Controller
    Get.lazyPut(
      () => EventoController(
        repository: Get.find<EventoRepository>(),
      ),
    );
  }
}