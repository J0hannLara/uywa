import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/session_controller.dart';
import '../../../home/navigation/main_navigation_page.dart';
import 'complete_profile_step1_page.dart';
import 'complete_profile_step2_page.dart';
import 'complete_profile_step3_page.dart';
import 'package:mypets/features/login/presentation/pages/login_page.dart';
import 'package:mypets/core/bindings/authenticated_bindings.dart';

class AuthGate extends StatelessWidget {

  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {

    final session =
        Get.find<SessionController>();

    return Obx(() {

      final user =
          session.currentUser.value;

      if (session.isLoading.value) {
        return const Scaffold(
          body: Center(
            child:
                CircularProgressIndicator(),
          ),
        );
      }

      if (user == null) {
        return LoginPage();
      }

      if (user.onboardingStep == 1) {
        return CompleteProfileStep1Page();
      }

      if (user.onboardingStep == 2) {
        return CompleteProfileStep2Page();
      }

      if (user.onboardingStep == 3) {
        return CompleteProfileStep3Page();
      }

      // Usuario autenticado y onboarding completo

      AuthenticatedBindings()
          .dependencies();

      return const MainNavigationPage();
    });
  }
}