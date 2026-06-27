import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDatasource {
  final SupabaseClient supabase;

  AuthRemoteDatasource(this.supabase);

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'bo.mypets.app://login-callback',
    );
  }

  User? get currentUser => supabase.auth.currentUser;

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}