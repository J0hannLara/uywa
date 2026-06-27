import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypets/core/helpers/main_navigation_helper.dart';
import 'package:mypets/core/theme/app_colors.dart';
import '../../../mascotas/presentation/widgets/mascota_form_widget.dart';
import 'package:mypets/features/perfiles/presentation/controllers/perfiles_controller.dart';

class CompleteProfileStep3Page
    extends StatelessWidget {

  CompleteProfileStep3Page({
    super.key,
  });

  final controller =
      Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: context.colors.cardBackground,

        automaticallyImplyLeading:
            false,

        title: Text(
          'Registra tu mascota',
          style: TextStyle(color: context.colors.textPrimary),
        ),

        actions: [

          TextButton(

            onPressed: () async {

              await controller
                  .finishOnboarding();

              await goToMainApp();
            },

            child: const Text(
              'Omitir',
            ),
          ),
        ],
      ),

      body: Column(

        children: [

          Expanded(
            child:
                MascotaFormWidget(),
          ),

        ],
      ),
    );
  }
}