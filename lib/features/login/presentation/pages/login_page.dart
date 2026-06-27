import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypets/app/services/supabase_service.dart';
import 'package:mypets/features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../../core/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final authService = AuthRemoteDatasource(SupabaseService.client);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo decorativo
            _buildBackgroundDecoration(context),
            
            // Contenido principal
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo y animación
                    _buildLogoSection(context),
                    
                    const SizedBox(height: 40),
                    
                    // Texto de bienvenida
                    _buildWelcomeText(context),
                    
                    const SizedBox(height: 48),
                    
                    // Botón de Google
                    _buildGoogleButton(context),
                    
                    const SizedBox(height: 24),
                    
                    // Términos y condiciones
                    _buildTermsText(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration(BuildContext context,) {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              context.colors.primary.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context,) {
    return Column(
      children: [
        // Contenedor del logo con efecto de sombra
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.primary,
                context.colors.primaryLight,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/logosf.png', // Cambia por la ruta de tu logo
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Nombre de la app
        Text(
          'UYWA',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  context.colors.primary,
                  context.colors.primaryLight,
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
          ),
        ),
        const SizedBox(height: 8),
        
        // Tagline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: context.colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '🐾 Encuentra a tu mejor amigo 🐾',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText(BuildContext context,) {
    return Column(
      children: [
        Text(
          '¡Bienvenido!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Conecta con personas que aman las mascotas\ntanto como tú',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton(BuildContext context,) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 350),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary,
            context.colors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              await authService.signInWithGoogle();
            } catch (e) {
              Get.snackbar(
                'Error',
                e.toString(),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withOpacity(0.9),
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de Google
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Continuar con Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText(BuildContext context,) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            'Al continuar, aceptas los',
            style: TextStyle(
              fontSize: 11,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // Navegar a términos y condiciones
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Términos de servicio',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                ' y ',
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegar a privacidad
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Política de privacidad',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}