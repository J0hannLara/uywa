import 'package:get/get.dart';
import '../bindings/authenticated_bindings.dart';
import 'package:mypets/features/home/navigation/main_navigation_page.dart';

Future<void> goToMainApp() async {
  // Registrar dependencias
  AuthenticatedBindings().dependencies();

  // Navegar a la app principal
  await Get.offAll(() => const MainNavigationPage());
}
