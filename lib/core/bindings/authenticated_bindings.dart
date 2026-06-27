import 'package:get/get.dart';
import 'package:mypets/features/eventos/bindings/evento_bindings.dart';
import 'package:mypets/features/insignias/bindings/insignias_binding.dart';
import 'package:mypets/features/perdidas/bindings/perdidas_binding.dart';
import 'package:mypets/features/publicaciones/bindings/publicaciones_binding.dart';
import 'package:mypets/features/albergues/bindings/albergues_binding.dart';

class AuthenticatedBindings extends Bindings {
  @override
  void dependencies() {

    // PUBLICACIONES

    PublicacionBinding().dependencies();

    AlbergueBinding().dependencies();

    InsigniaBinding().dependencies();

    EventoBinding().dependencies();

    PerdidaBinding().dependencies();

    // MASCOTAS

    /* MascotaBinding().dependencies(); */

    // NOTIFICACIONES

    // NotificacionBinding().dependencies();

    // ALBERGUES

    // AlbergueBinding().dependencies();
  }
}