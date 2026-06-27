import 'package:flutter/material.dart';
import 'package:mypets/features/mascotas/presentation/widgets/mascota_form_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/home/navigation/main_navigation_page.dart';
import 'package:get/get.dart';
import 'package:mypets/features/perfiles/presentation/controllers/perfiles_controller.dart';
// RegistrarMascotaPage
class RegistrarMascotaPage extends StatelessWidget {
  const RegistrarMascotaPage({super.key});
  
  @override
  Widget build(BuildContext context) {
  final controllerProfile = Get.find<ProfileController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar mascota',
          style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary),
        ),
        backgroundColor: context.colors.cardBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await controllerProfile.finishOnboarding();

              Get.offAll(() => const MainNavigationPage());
            },

            child: const Text('Omitir'),
          ),
        ],
      ),
      body: const MascotaFormWidget(),
    );
  }
}
