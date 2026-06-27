// lib/features/perfiles/presentation/pages/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypets/core/services/profile_avatar_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/perfiles_controller.dart';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileController controller = Get.find<ProfileController>();
  
  late TextEditingController nombreController;
  late TextEditingController usernameController;
  late TextEditingController descripcionController;
  late TextEditingController telefonoController;
  late TextEditingController ciudadController;
  late TextEditingController paisController;

  @override
  void initState() {
    super.initState();
    final user = controller.profile.value;
    
    nombreController = TextEditingController(text: user?.nombre ?? '');
    usernameController = TextEditingController(text: user?.username ?? '');
    descripcionController = TextEditingController(text: user?.descripcion ?? '');
    telefonoController = TextEditingController(text: user?.telefono ?? '');
    ciudadController = TextEditingController(text: user?.ciudad ?? '');
    paisController = TextEditingController(text: user?.pais ?? '');
  }

  @override
  void dispose() {
    nombreController.dispose();
    usernameController.dispose();
    descripcionController.dispose();
    telefonoController.dispose();
    ciudadController.dispose();
    paisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _guardarCambios,
            child: Obx(() => controller.isLoading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.primary,
                    ),
                  )
                : Text(
                    'Guardar',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.profile.value;
        if (user == null) return const SizedBox();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    ProfileAvatar(
                      imageUrl: user.fotoPerfil,
                      radius: 60,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showAvatarOptions(context, controller),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.colors.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Formulario
              _buildTextField(
                context: context,
                label: 'Nombre completo',
                controller: nombreController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                context: context,
                label: 'Username',
                controller: usernameController,
                icon: Icons.alternate_email,
                enabled: !controller.isLoading.value,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                context: context,
                label: 'Descripción',
                controller: descripcionController,
                icon: Icons.description_outlined,
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                context: context,
                label: 'Teléfono',
                controller: telefonoController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                context: context,
                label: 'Ciudad',
                controller: ciudadController,
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                context: context,
                label: 'País',
                controller: paisController,
                icon: Icons.public_outlined,
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          enabled: enabled,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: context.colors.primary,
              size: 22,
            ),
            filled: true,
            fillColor: context.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colors.error,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            counterStyle: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _guardarCambios() async {
    final user = controller.profile.value;
    if (user == null) return;

    // Validaciones básicas
    if (usernameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'El username es requerido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.colors.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Actualizar usando los métodos existentes
      await controller.completeStep1(
        nombre: nombreController.text,
        telefono: telefonoController.text,
        ciudad: ciudadController.text,
        pais: paisController.text,
      );

      // Verificar si username cambió
      if (usernameController.text != user.username) {
        await controller.completeStep2(
          username: usernameController.text,
          descripcion: descripcionController.text,
        );
      }

      if (context.mounted) {
        Navigator.pop(context);
        Get.snackbar(
          'Éxito',
          'Perfil actualizado correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: context.colors.success,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el perfil',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.colors.error,
        colorText: Colors.white,
      );
    }
  }

  void _showAvatarOptions(BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: context.colors.primary,
                ),
              ),
              title: Text(
                'Cambiar foto de perfil',
                style: TextStyle(color: context.colors.textPrimary),
              ),
              subtitle: Text(
                'Selecciona una imagen de tu galería',
                style: TextStyle(color: context.colors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Info',
                  'Funcionalidad en desarrollo',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: context.colors.info,
                  colorText: Colors.white,
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: context.colors.error,
                ),
              ),
              title: Text(
                'Eliminar foto',
                style: TextStyle(color: context.colors.textPrimary),
              ),
              subtitle: Text(
                'Volver a la foto por defecto',
                style: TextStyle(color: context.colors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implementar eliminación de foto
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}