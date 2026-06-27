// lib/features/perfiles/presentation/pages/opciones_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypets/core/services/profile_avatar_service.dart';
import 'package:mypets/features/perfiles/presentation/pages/edit_profile_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/options_controller.dart';
import '../controllers/perfiles_controller.dart';

class OpcionesPage extends StatelessWidget {
  const OpcionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OpcionesController controller = Get.put(OpcionesController());
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        backgroundColor: context.colors.cardBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final user = profileController.profile.value;

        return ListView(
          children: [
            // Header con información del usuario
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(
                  bottom: BorderSide(color: context.colors.border),
                ),
              ),
              child: Row(
                children: [
                  ProfileAvatar(imageUrl: user?.fotoPerfil, radius: 35),
                  const SizedBox(width: 16),
                  // Información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nombre ?? 'Usuario',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        if (user?.username != null)
                          Text(
                            '@${user!.username}',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Verificación
                  if (user?.verificado == true)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Sección: Mi cuenta
            _buildSectionHeader(context, 'Mi cuenta', Icons.person_outline),

            _buildMenuItem(
              context: context,
              icon: Icons.edit_outlined,
              title: 'Editar perfil',
              subtitle: 'Información personal y foto',
              onTap: () => Get.to(EditProfilePage()),
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.pets_outlined,
              title: 'Mis mascotas',
              subtitle: 'Gestionar mis mascotas registradas',
              onTap: () => Get.toNamed('/my-pets'),
              showBadge: true,
              badgeCount: 3,
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.favorite_outline,
              title: 'Mascotas favoritas',
              subtitle: 'Mascotas que me han gustado',
              onTap: () {},
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.article_outlined,
              title: 'Mis publicaciones',
              subtitle: 'Gestionar mis posts',
              onTap: () {},
            ),

            const Divider(height: 1),

            // Sección: Privacidad y seguridad
            _buildSectionHeader(
              context,
              'Privacidad y seguridad',
              Icons.lock_outline,
            ),

            _buildSwitchMenuItem(
              context: context,
              icon: Icons.visibility_off_outlined,
              title: 'Cuenta privada',
              subtitle: 'Solo tus seguidores pueden ver tu contenido',
              value: controller.privateAccount.value,
              onChanged: controller.togglePrivateAccount,
            ),

            _buildSwitchMenuItem(
              context: context,
              icon: Icons.email_outlined,
              title: 'Mostrar email',
              subtitle: 'Permitir que otros vean tu email',
              value: controller.showEmail.value,
              onChanged: controller.toggleNotifications,
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.block_outlined,
              title: 'Usuarios bloqueados',
              subtitle: 'Gestionar usuarios bloqueados',
              onTap: () {},
            ),

            const Divider(height: 1),

            // Sección: Notificaciones
            _buildSectionHeader(
              context,
              'Notificaciones',
              Icons.notifications_none,
            ),

            _buildSwitchMenuItem(
              context: context,
              icon: Icons.notifications_active_outlined,
              title: 'Notificaciones push',
              subtitle: 'Recibir alertas en tu dispositivo',
              value: controller.notificationsEnabled.value,
              onChanged: controller.toggleNotifications,
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.pets_outlined,
              title: 'Alertas de adopción',
              subtitle: 'Notificaciones sobre nuevas mascotas',
              onTap: () {},
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Premium',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.message_outlined,
              title: 'Mensajes',
              subtitle: 'Notificaciones de mensajes',
              onTap: () {},
            ),

            const Divider(height: 1),

            // Sección: Preferencias
            _buildSectionHeader(
              context,
              'Preferencias',
              Icons.settings_outlined,
            ),

            _buildSwitchMenuItem(
              context: context,
              icon: Icons.dark_mode_outlined,
              title: 'Modo oscuro',
              subtitle: 'Cambiar tema de la app',
              value: controller.darkModeEnabled.value,
              onChanged: controller.toggleDarkMode,
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.language_outlined,
              title: 'Idioma',
              subtitle: 'Español',
              onTap: () {},
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.photo_library_outlined,
              title: 'Calidad de imagen',
              subtitle: 'Alta calidad',
              onTap: () {},
            ),

            const Divider(height: 1),

            // Sección: Soporte
            _buildSectionHeader(
              context,
              'Soporte',
              Icons.support_agent_outlined,
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.help_outline,
              title: 'Centro de ayuda',
              subtitle: 'Preguntas frecuentes y guías',
              onTap: () {},
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.feedback_outlined,
              title: 'Enviar feedback',
              subtitle: 'Ayúdanos a mejorar',
              onTap: () {},
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.star_outline,
              title: 'Valorar la app',
              subtitle: 'Califícanos en la Play Store',
              onTap: () {},
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.info_outline,
              title: 'Acerca de',
              subtitle: 'Versión 1.0.0',
              onTap: () {},
            ),

            const Divider(height: 1),

            // Sección: Peligro
            _buildSectionHeader(
              context,
              'Datos',
              Icons.warning_amber_outlined,
              isDanger: true,
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.download_outlined,
              title: 'Exportar mis datos',
              subtitle: 'Descargar toda tu información',
              onTap: () {},
              textColor: Colors.orange,
            ),

            _buildMenuItem(
              context: context,
              icon: Icons.delete_outline,
              title: 'Eliminar cuenta',
              subtitle: 'Eliminar permanentemente mi cuenta',
              onTap: controller.deleteAccount,
              textColor: Colors.red,
            ),
            

            const SizedBox(height: 20),

            // Botón de cerrar sesión
            Container(
              margin: const EdgeInsets.all(20),
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.signOut,
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.logout),
                  label: Text(
                    controller.isLoading.value
                        ? 'Cerrando sesión...'
                        : 'Cerrar sesión',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDanger ? Colors.red : context.colors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDanger ? Colors.red : context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? textColor,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: context.colors.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor ?? context.colors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
      ),
      trailing: showBadge
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildSwitchMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: context.colors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: context.colors.primary,
            activeTrackColor: context.colors.primaryLight,
          ),
        ],
      ),
    );
  }
}
