import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/session_controller.dart';

import '../../../perfiles/presentation/controllers/perfiles_controller.dart';

class AuthService extends GetxController {
  final supabase = Supabase.instance.client;

  final session = Get.find<SessionController>();

  final profileService = Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();
    print('AUTH SERVICE INICIADO');

    listenAuthChanges();
  }

  void listenAuthChanges() {
    supabase.auth.onAuthStateChange.listen((data) async {
      print('EVENTO AUTH: ${data.event}');

      final authSession = data.session;

      if (authSession != null) {
        print('SESSION DETECTADA');

        await profileService.cargarUsuario();
      } else {
        print('SESSION NULL');

        session.currentUser.value = null;
      }
    });
  }

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,

      redirectTo: 'bo.mypets.app://login-callback',
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();

    session.currentUser.value = null;
  }
}
