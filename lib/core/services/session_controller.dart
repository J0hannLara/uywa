import 'package:get/get.dart';
import '../../features/auth/data/models/usuario_model.dart';

class SessionController extends GetxController {

  Rxn<UsuarioModel> currentUser =
      Rxn<UsuarioModel>();

  RxBool isLoading = false.obs;

  bool get isAuthenticated =>
      currentUser.value != null;
}