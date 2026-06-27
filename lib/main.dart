import 'package:flutter/material.dart';
import 'package:mypets/app/services/supabase_service.dart';
import 'package:get/get.dart';
import 'package:mypets/core/cache/cache_service.dart';
import 'package:mypets/core/bindings/app_bindings.dart';
import 'package:mypets/core/services/notification_service.dart';
import 'package:mypets/core/services/theme_service.dart';
import 'package:mypets/features/auth/presentation/pages/splash_page.dart';
import 'package:mypets/firebase_options.dart';
import 'core/cache/hive_cache_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SupabaseService.initialize();
  
  await NotificationService.initialize();

  await CacheService.init();

  await Hive.initFlutter();
  final hiveCacheService = HiveCacheService();
  await hiveCacheService.init();
  Get.put<HiveCacheService>(hiveCacheService);
  Get.put(ThemeService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      initialBinding: AppBindings(),

      home: const SplashPage(),
    );
  }
}
