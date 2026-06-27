import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypets/features/perfiles/presentation/controllers/perfiles_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/session_controller.dart';

class CompleteProfileStep1Page extends StatefulWidget {
  const CompleteProfileStep1Page({super.key});

  @override
  State<CompleteProfileStep1Page> createState() =>
      _CompleteProfileStep1PageState();
}

class _CompleteProfileStep1PageState extends State<CompleteProfileStep1Page>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(ProfileController());
  final session = Get.find<SessionController>();
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final ciudadController = TextEditingController();
  final paisController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    loadUserData();

    // INICIALIZAR CORRECTAMENTE LAS ANIMACIONES
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

    // INICIAR LA ANIMACIÓN
    _animationController.forward();
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    ciudadController.dispose();
    paisController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void loadUserData() {
    final user = session.currentUser.value;
    if (user == null) return;
    nombreController.text = user.nombre ?? '';
    telefonoController.text = user.telefono ?? '';
    ciudadController.text = user.ciudad ?? '';
    paisController.text = user.pais ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text(
          'Completa tu perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
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
                // Header con ilustración
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: context.colors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add_alt_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Cuéntanos sobre ti',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completa tus datos para conectar\ncon más personas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

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
                            'Paso 1 de 3',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Información básica',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.33,
                        backgroundColor: context.colors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colors.primary,
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
                        // Campo de Nombre
                        _buildInputField(
                          context: context,
                          controller: nombreController,
                          label: 'Nombre completo',
                          hint: 'Ej: María González',
                          icon: Icons.person_outline,
                          prefixIconColor: context.colors.primary,
                        ),

                        const SizedBox(height: 20),

                        // Campo de Teléfono
                        _buildInputField(
                          context: context,
                          controller: telefonoController,
                          label: 'Teléfono',
                          hint: 'Ej: 71234567',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          prefixIconColor: context.colors.secondary,
                        ),

                        const SizedBox(height: 20),

                        // Campo de Ciudad
                        _buildInputField(
                          context: context,
                          controller: ciudadController,
                          label: 'Ciudad',
                          hint: 'Ej: La Paz',
                          icon: Icons.location_city_outlined,
                          prefixIconColor: context.colors.accent,
                        ),

                        const SizedBox(height: 20),

                        // Campo de País
                        _buildInputField(
                          context: context,
                          controller: paisController,
                          label: 'País',
                          hint: 'Ej: Bolivia',
                          icon: Icons.public_outlined,
                          prefixIconColor: context.colors.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botón Continuar
                Obx(() {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              controller.completeStep1(
                                nombre: nombreController.text,
                                telefono: telefonoController.text,
                                ciudad: ciudadController.text,
                                pais: paisController.text,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
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
                                  'Continuar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Texto de ayuda
                Center(
                  child: Text(
                    'Tus datos son seguros y solo serán visibles\npara otros usuarios cuando tú lo decidas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textTertiary,
                      height: 1.5,
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

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Color? prefixIconColor,
  }) {
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
          style: TextStyle(color: context.colors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 14,
            ),
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
}
