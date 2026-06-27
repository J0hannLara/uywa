import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:mypets/features/auth/data/models/usuario_model.dart';

class AuthService extends GetxController {
  final supabase = Supabase.instance.client;

  Rxn<UsuarioModel> currentUser = Rxn<UsuarioModel>();

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    listenAuthChanges();
  }

  void listenAuthChanges() {
    supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;

      if (session != null) {
        await cargarUsuario();
      } else {
        currentUser.value = null;
      }
    });
  }

  Future<UsuarioModel?> cargarUsuario() async {
    try {
      isLoading.value = true;

      final authUser = supabase.auth.currentUser;

      if (authUser == null) {
        return null;
      }

      final response = await supabase
          .from('usuarios')
          .select()
          .eq('id', authUser.id)
          .single();

      final usuario = UsuarioModel.fromJson(response);

      currentUser.value = usuario;

      return usuario;
    } catch (e) {
      print('ERROR cargarUsuario: $e');

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();

    currentUser.value = null;
  }

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'bo.mypets.app://login-callback',
    );
  }

  Future<void> checkUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final data = await Supabase.instance.client
        .from('usuarios')
        .select()
        .eq('id', user.id)
        .single();

    final perfilCompleto = data['perfil_completo'] ?? false;

    if (perfilCompleto) {
    } else {}
  }
}
