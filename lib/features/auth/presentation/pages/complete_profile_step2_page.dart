import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypets/features/perfiles/presentation/controllers/perfiles_controller.dart';
import '../../../../core/theme/app_colors.dart';

// Enum al nivel superior
enum AvatarOption { google, asset1, asset2, asset3 }

class CompleteProfileStep2Page extends StatefulWidget {
  const CompleteProfileStep2Page({super.key});

  @override
  State<CompleteProfileStep2Page> createState() =>
      _CompleteProfileStep2PageState();
}

class _CompleteProfileStep2PageState extends State<CompleteProfileStep2Page>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(ProfileController());
  final usernameController = TextEditingController();
  final descripcionController = TextEditingController();

  // Opciones de avatar
  AvatarOption? selectedAvatarOption;

  // URL de Google (obtenida del perfil del usuario)
  String? googleAvatarUrl;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Obtener la imagen de Google del perfil actual
    final currentUser = controller.profile.value;
    if (currentUser?.fotoPerfil != null &&
        currentUser!.fotoPerfil!.isNotEmpty) {
      googleAvatarUrl = currentUser.fotoPerfil;
    }

    // Si hay imagen de Google, seleccionarla por defecto
    if (googleAvatarUrl != null && googleAvatarUrl!.isNotEmpty) {
      selectedAvatarOption = AvatarOption.google;
    } else {
      // Si no hay imagen de Google, seleccionar el primer asset por defecto
      selectedAvatarOption = AvatarOption.asset1;
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    usernameController.dispose();
    descripcionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Obtener la imagen actual según la opción seleccionada
  Widget _getCurrentAvatar({double radius = 60}) {
    if (selectedAvatarOption == AvatarOption.google &&
        googleAvatarUrl != null) {
      // Imagen de Google (Network)
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(googleAvatarUrl!),
        backgroundColor: context.colors.cardBackground,
      );
    } else if (selectedAvatarOption == AvatarOption.asset1) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage('assets/foto_perfil_1.png'),
        backgroundColor: context.colors.cardBackground,
      );
    } else if (selectedAvatarOption == AvatarOption.asset2) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage('assets/foto_perfil_2.png'),
        backgroundColor: context.colors.cardBackground,
      );
    } else if (selectedAvatarOption == AvatarOption.asset3) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage('assets/foto_perfil_3.png'),
        backgroundColor: context.colors.cardBackground,
      );
    } else {
      // Fallback: icono por defecto
      return CircleAvatar(
        radius: radius,
        backgroundColor: context.colors.cardBackground,
        child: Icon(
          Icons.person_add_alt_rounded,
          size: radius * 0.7,
          color: context.colors.textSecondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          'Perfil público',
          style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary),
        ),
        backgroundColor: context.colors.cardBackground,
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: context.colors.secondaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.secondary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.public,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tu perfil público',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cómo te verán los demás usuarios',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Indicador de progreso
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Paso 2 de 3',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Perfil público',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.66,
                        backgroundColor: context.colors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colors.secondary,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Card del formulario
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar principal
                        Center(
                          child: Column(
                            children: [
                              _getCurrentAvatar(radius: 60),
                              const SizedBox(height: 12),
                              Text(
                                'Selecciona tu foto de perfil',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Elige una de las opciones disponibles',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Opciones de avatar
                        Text(
                          'Opciones de foto de perfil',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Grid de opciones
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            // Opción Google
                            if (googleAvatarUrl != null &&
                                googleAvatarUrl!.isNotEmpty)
                              _buildAvatarOption(
                                label: 'Google',
                                isSelected:
                                    selectedAvatarOption == AvatarOption.google,
                                onTap: () {
                                  setState(() {
                                    selectedAvatarOption = AvatarOption.google;
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    googleAvatarUrl!,
                                  ),
                                  backgroundColor: context.colors.cardBackground,
                                ),
                              ),

                            // Opción Asset 1
                            _buildAvatarOption(
                              label: 'Avatar 1',
                              isSelected:
                                  selectedAvatarOption == AvatarOption.asset1,
                              onTap: () {
                                setState(() {
                                  selectedAvatarOption = AvatarOption.asset1;
                                });
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: const AssetImage(
                                  'assets/foto_perfil_1.png',
                                ),
                                backgroundColor: context.colors.cardBackground,
                              ),
                            ),

                            // Opción Asset 2
                            _buildAvatarOption(
                              label: 'Avatar 2',
                              isSelected:
                                  selectedAvatarOption == AvatarOption.asset2,
                              onTap: () {
                                setState(() {
                                  selectedAvatarOption = AvatarOption.asset2;
                                });
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: const AssetImage(
                                  'assets/foto_perfil_2.png',
                                ),
                                backgroundColor: context.colors.cardBackground,
                              ),
                            ),

                            // Opción Asset 3
                            _buildAvatarOption(
                              label: 'Avatar 3',
                              isSelected:
                                  selectedAvatarOption == AvatarOption.asset3,
                              onTap: () {
                                setState(() {
                                  selectedAvatarOption = AvatarOption.asset3;
                                });
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: const AssetImage(
                                  'assets/foto_perfil_3.png',
                                ),
                                backgroundColor: context.colors.cardBackground,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Campo Username
                        _buildInputField(
                          context: context,
                          controller: usernameController,
                          label: 'Nombre de usuario',
                          hint: '@usuario',
                          icon: Icons.alternate_email,
                          prefixIconColor: context.colors.secondary,
                        ),

                        const SizedBox(height: 20),

                        // Campo Descripción
                        _buildInputField(
                          context: context,
                          controller: descripcionController,
                          label: 'Biografía',
                          hint:
                              'Cuéntanos sobre ti y tu amor por los animales...',
                          icon: Icons.description_outlined,
                          prefixIconColor: context.colors.secondary,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botón Finalizar
                Obx(() {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              _completeProfile();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Finalizar registro',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.check_circle_outline, size: 20),
                              ],
                            ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Texto de ayuda
                Center(
                  child: Text(
                    'Esta información será visible para otros usuarios',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? context.colors.secondary : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: context.colors.secondary.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? context.colors.secondary : context.colors.textTertiary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Color? prefixIconColor,
    int maxLines = 1,
  })  {
    final color = prefixIconColor ?? context.colors.primary;
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
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: context.colors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.colors.textTertiary, fontSize: 14),
            prefixIcon: Icon(icon, color: prefixIconColor, size: 22),
            filled: true,
            fillColor: context.colors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.colors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _completeProfile() async {
    // Validar username
    if (usernameController.text.isEmpty) {
      Get.snackbar('Error', 'Por favor ingresa un nombre de usuario');
      return;
    }

    // Validar que haya seleccionado una opción de avatar
    if (selectedAvatarOption == null) {
      Get.snackbar('Error', 'Por favor selecciona una foto de perfil');
      return;
    }

    // Obtener la URL o path de la imagen seleccionada
    String? avatarUrl;

    if (selectedAvatarOption == AvatarOption.google) {
      avatarUrl = googleAvatarUrl;
    } else if (selectedAvatarOption == AvatarOption.asset1) {
      avatarUrl = 'assets/foto_perfil_1.png';
    } else if (selectedAvatarOption == AvatarOption.asset2) {
      avatarUrl = 'assets/foto_perfil_2.png';
    } else if (selectedAvatarOption == AvatarOption.asset3) {
      avatarUrl = 'assets/foto_perfil_3.png';
    }

    // Si no hay URL (por si acaso), mostrar error
    if (avatarUrl == null || avatarUrl.isEmpty) {
      Get.snackbar('Error', 'No se pudo obtener la imagen de perfil');
      return;
    }

    await controller.completeStep2(
      username: usernameController.text,
      descripcion: descripcionController.text,
      avatarUrl: avatarUrl,
    );
  }
}
