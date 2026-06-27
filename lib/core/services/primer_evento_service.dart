import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/eventos/presentation/controllers/evento_controller.dart';
import 'package:mypets/features/insignias/presentation/controllers/insignias_controller.dart';
import 'package:mypets/features/insignias/data/models/insignias_model.dart';
import '../theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrimerEventoService {
  static const int EVENTO_ID = 3; // Primeras Huellitas
  static const int INSIGNIA_ID = 5; // Insignia "Primerizo"

  // Verificar y asignar insignia
  static Future<bool> verificarYAsignarInsignia(BuildContext context) async {
    try {
      final InsigniaController insigniaController = Get.find<InsigniaController>();
      final EventoController eventoController = Get.find<EventoController>();
      final supabase = Supabase.instance.client;
      
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;
        print('Iniciando verificación, userID:');
        print(userId);


      // 1. Obtener la insignia
      final insignia = await insigniaController.getInsigniaById(INSIGNIA_ID);
      if (insignia == null) {
        print('Insignia no encontrada');
        return false;
      }

      // 2. Verificar si el evento sigue activo
      final eventoActivo = await _eventoEstaActivo(eventoController);
      if (!eventoActivo) {
        print('Evento no está activo');
        return false;
      }

      // 3. Verificar si el usuario ya tiene la insignia
      final tieneInsignia = await insigniaController.usuarioTieneInsignia(
        INSIGNIA_ID,
        userId,
      );
      if (tieneInsignia) {
        print('Usuario ya tiene la insignia');
        return false;
      }

      // 4. Verificar si el usuario ya participa en el evento
      final participa = await eventoController.usuarioParticipaEnEvento(EVENTO_ID, userId);
      
      if (!participa) {
        await eventoController.unirseEvento(EVENTO_ID);
      }

      // 5. Verificar si ya reclamó el evento
      final reclamo = await eventoController.usuarioReclamoEvento(EVENTO_ID, userId);
      if (reclamo) {
        print('Usuario ya reclamó el evento');
        return false;
      }

      // 6. Reclamar la insignia
      await eventoController.reclamarInsignia(EVENTO_ID);

      // 7. Mostrar modal de felicitación
      await _mostrarModalFelicitacion(context, insignia);

      return true;

    } catch (e) {
      print('Error verificando insignia: $e');
      return false;
    }
  }

  static Future<bool> _eventoEstaActivo(EventoController eventoController) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final evento = await eventoController.repository.getEventoById(
        id: EVENTO_ID,
        userId: userId,
      );
      
      if (evento == null) return false;
      
      return evento.activo && evento.fechaFin.isAfter(DateTime.now());
    } catch (e) {
      print('Error verificando evento activo: $e');
      return false;
    }
  }

  static Future<void> _mostrarModalFelicitacion(BuildContext context, InsigniaModel insignia) async {
    await Get.dialog(
      Dialog(
        backgroundColor: context.colors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de celebración
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  size: 40,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 16),
             Text(
                '🎉 ¡Felicidades! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Has obtenido la insignia',
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              // Mostrar la insignia
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.border),
                ),
                child: Column(
                  children: [
                    // Icono de la insignia
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: insignia.imagen != null
                          ? SvgPicture.asset(
                              insignia.imagen!,
                              width: 40,
                              height: 40,
                              color: context.colors.primary,
                              placeholderBuilder: (context) => Icon(
                                Icons.emoji_events,
                                size: 40,
                                color: context.colors.primary,
                              ),
                            )
                          : Icon(
                              Icons.emoji_events,
                              size: 40,
                              color: context.colors.primary,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      insignia.nombre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                insignia.descripcion ?? '¡Primera insignia obtenida!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '¡Genial!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}