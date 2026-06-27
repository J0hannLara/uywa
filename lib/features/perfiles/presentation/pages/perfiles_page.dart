// lib/features/perfiles/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypets/features/insignias/presentation/controllers/insignias_controller.dart';
import 'package:mypets/features/perfiles/presentation/pages/profile_options_page.dart';
import 'package:mypets/features/publicaciones/presentation/controllers/publicaciones_controller.dart';
import 'package:mypets/features/publicaciones/presentation/widgets/publicaciones_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/perfiles_controller.dart';
import 'edit_profile_page.dart';
import 'package:mypets/features/mascotas/presentation/controllers/mascotas_controller.dart';
import 'package:mypets/features/mascotas/data/models/mascotas_model.dart';
import 'package:mypets/core/services/profile_avatar_service.dart';
import '../../../mascotas/presentation/pages/mascota_detail_page.dart';
import '../../../mascotas/presentation/pages/registrar_mascota_page.dart';
import 'package:flutter_svg/flutter_svg.dart ';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    final MascotaController controllerMascota = Get.find<MascotaController>();
    final InsigniaController insigniaController =
        Get.find<InsigniaController>();
    final PublicacionController publicacionController =
        Get.find<PublicacionController>(); // 👈 Agregar

    // Cargar publicaciones del usuario al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = controller.profile.value;
      if (user != null) {
        publicacionController.loadMisPublicaciones(reiniciar: true);
      }
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        backgroundColor: context.colors.cardBackground,
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Get.to(() => const EditProfilePage()),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.to(OpcionesPage()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.profile.value == null) {
          return _buildShimmerLoading();
        }

        if (controller.profile.value == null) {
          return _buildErrorWidget(context, controller);
        }

        final user = controller.profile.value!;

        // Cargar insignias solo una vez
        if (insigniaController.insigniasDeUsuario.isEmpty &&
            !insigniaController.isLoading.value &&
            !insigniaController.insigniasCargadas.value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            insigniaController.loadInsigniasDeUsuario(user.id);
          });
        }

        return RefreshIndicator(
          onRefresh: () => controller.cargarUsuario(),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: _buildProfileHeader(
                    context,
                    user,
                    controller,
                    insigniaController,
                  ),
                ),
              ];
            },
            body: RefreshIndicator(
              onRefresh: () async {
                await controller.cargarUsuario();
                await publicacionController.refreshMisPublicaciones();
                await controllerMascota.refreshMascotas();
              },
              color: context.colors.primary,
              child: CustomScrollView(
                slivers: [
                  // Sección "Mis Mascotas"
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      context,
                      title: 'Mis Mascotas',
                      icon: Icons.pets,
                      onSeeAll: () {},
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildHorizontalPetsList(context)),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Sección "Publicaciones"
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      context,
                      title: 'Mis Publicaciones',
                      icon: Icons.article_outlined,
                      onSeeAll: () {},
                    ),
                  ),

                  // 👇 Lista de publicaciones reales
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index <
                            publicacionController.misPublicaciones.length) {
                          final post =
                              publicacionController.misPublicaciones[index];
                          return PostCard(
                            post: post,
                            onTap: () {
                              // Navegar a detalle de la publicación
                              // Get.to(() => PublicacionDetailPage(post: post));
                            },
                          );
                        } else {
                          // Cargar más publicaciones si hay más
                          if (publicacionController.hayMasMis.value &&
                              !publicacionController.isLoadingMis.value) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              publicacionController.cargarMasMis();
                            });
                          }
                          return const SizedBox.shrink();
                        }
                      },
                      childCount:
                          publicacionController.misPublicaciones.length +
                          (publicacionController.hayMasMis.value ? 1 : 0),
                    ),
                  ),

                  // Indicador de carga de más publicaciones
                  SliverToBoxAdapter(
                    child: Obx(() {
                      if (publicacionController.isLoadingMis.value &&
                          publicacionController.misPublicaciones.isNotEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (!publicacionController.hayMasMis.value &&
                          publicacionController.misPublicaciones.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No hay más publicaciones',
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    dynamic user,
    ProfileController controller,
    InsigniaController insigniaController,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              ProfileAvatar(
                imageUrl: user.fotoPerfil,
                radius: 55,
                onTap: () => _showAvatarOptions(context, controller),
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
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nombre
          Text(
            user.nombre ?? 'Sin nombre',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Username
          if (user.username != null)
            Text(
              '@${user.username}',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 14,
              ),
            ),

          // Email
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 14,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                user.email,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Descripción
          if (user.descripcion != null && user.descripcion!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.descripcion!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),

          // Ubicación
          if (user.ciudad != null || user.pais != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    [
                      user.ciudad,
                      user.pais,
                    ].where((e) => e != null && e!.isNotEmpty).join(', '),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

          // Teléfono
          if (user.telefono != null && user.telefono!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                    size: 14,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.telefono!,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(context, 'Mascotas', 0),
                Container(width: 1, height: 40, color: context.colors.border),
                _buildStat(context, 'Publicaciones', 0),
                Container(width: 1, height: 40, color: context.colors.border),
                _buildStat(context, 'Seguidores', 0),
                Container(width: 1, height: 40, color: context.colors.border),
                _buildStat(context, 'Seguidos', 0),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Badges
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (user.verificado)
                _buildBadge('Verificado', Icons.verified, Colors.blue),
              if (user.perfilCompleto)
                _buildBadge(
                  'Perfil Completo',
                  Icons.check_circle,
                  Colors.green,
                ),
            ],
          ),

          const SizedBox(height: 24),

          // =========================
          // INSIGNIAS DEL USUARIO (SIN Obx anidado)
          // =========================
          _buildInsigniasSection(context, insigniaController),
        ],
      ),
    );
  }

  // =========================
  // SECCIÓN DE INSIGNIAS (SIN Obx anidado)
  // =========================
  Widget _buildInsigniasSection(BuildContext context, insigniaController) {
    // Usar un solo Obx para toda la sección
    return Obx(() {
      final isLoading = insigniaController.isLoading.value;
      final insignias = insigniaController.insigniasDeUsuario;
      final hasInsignias = insignias.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Row(
            children: [
              Icon(Icons.emoji_events, size: 20, color: context.colors.primary),
              const SizedBox(width: 8),
              Text(
                'Insignias',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              const Spacer(),
              // Botón "Ver todas" solo si tiene más de 3 insignias
              if (hasInsignias && insignias.length > 3)
                TextButton(
                  onPressed: () =>
                      _showAllInsigniasDialog(context, insigniaController),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                  ),
                  child: Text(
                    'Ver todas',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Contenido
          if (isLoading && insignias.isEmpty)
            const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (!hasInsignias)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 18,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Este usuario aún no tiene insignias',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...insignias
                    .take(3)
                    .map((insignia) => _buildInsigniaChip(context, insignia)),
                if (insignias.length > 3)
                  GestureDetector(
                    onTap: () =>
                        _showAllInsigniasDialog(context, insigniaController),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '+${insignias.length - 3}',
                            style: TextStyle(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'más',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildStat(BuildContext context, String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir una insignia individual
  Widget _buildInsigniaChip(BuildContext context, dynamic insignia) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: insignia.imagen != null
                  ? _buildInsigniaIcon(context, insignia.imagen!, size: 16)
                  : Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: context.colors.primary,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            insignia.nombre,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir el icono de la insignia (SVG o imagen)
  Widget _buildInsigniaIcon(
    BuildContext context,
    String imagenPath, {
    double size = 20,
  }) {
    if (imagenPath.endsWith('.svg')) {
      return SvgPicture.asset(
        imagenPath,
        width: size,
        height: size,
        color: context.colors.primary,
        placeholderBuilder: (context) =>
            Icon(Icons.emoji_events, size: size, color: context.colors.primary),
      );
    }
    return Image.asset(
      imagenPath,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.emoji_events,
          size: size,
          color: context.colors.primary,
        );
      },
    );
  }

  // Modal para mostrar todas las insignias
  void _showAllInsigniasDialog(
    BuildContext context,
    InsigniaController insigniaController,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 350,
          height: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: context.colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Todas las insignias',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: context.colors.textSecondary,
                    ),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Contador
              Obx(
                () => Text(
                  '${insigniaController.insigniasDeUsuario.length} insignias obtenidas',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Grid de insignias
              Expanded(
                child: Obx(() {
                  if (insigniaController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: insigniaController.insigniasDeUsuario.length,
                    itemBuilder: (context, index) {
                      final insignia =
                          insigniaController.insigniasDeUsuario[index];
                      return _buildInsigniaCard(context, insignia);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para mostrar cada insignia en el modal
  Widget _buildInsigniaCard(BuildContext context, dynamic insignia) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: insignia.imagen != null
                  ? _buildInsigniaIcon(context, insignia.imagen!, size: 28)
                  : Icon(
                      Icons.emoji_events,
                      size: 28,
                      color: context.colors.primary,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            insignia.nombre,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _showAvatarOptions(
    BuildContext context,
    ProfileController controller,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Cambiar foto de perfil'),
              onTap: () async {
                Navigator.pop(context);
                // Aquí puedes implementar la selección de imagen
                // Por ahora mostramos un mensaje
                Get.snackbar('Info', 'Funcionalidad en desarrollo');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorWidget(BuildContext context, ProfileController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el perfil',
            style: TextStyle(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.cargarUsuario(),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsTab(BuildContext context) {
    final controller = Get.find<MascotaController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.colors.primary,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Cargando tus mascotas...',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ],
          ),
        );
      }

      if (controller.mascotas.isEmpty) {
        return _buildEmptyState(context);
      }
      ElevatedButton.icon(
        onPressed: () {
          controller.loadMascotas();
        },
        icon: const Icon(Icons.refresh, size: 20),
        label: const Text('Recargar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

      return RefreshIndicator(
        onRefresh: () => controller.refreshMascotas(),
        color: context.colors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.mascotas.length,
          itemBuilder: (context, index) {
            final mascota = controller.mascotas[index];
            return _buildMascotaCard(context, mascota);
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: context.colors.primaryGradient.withOpacity(0.1),
            ),
            child: Icon(
              Icons.pets,
              size: 64,
              color: context.colors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aún no tienes mascotas registradas',
            style: TextStyle(
              fontSize: 16,
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registra a tu compañero para compartir\nsu historia y conectar con otros',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.textTertiary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Get.to(() => const RegistrarMascotaPage());
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Registrar mascota'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotaCard(BuildContext context, MascotaModel mascota) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navegar a detalle de mascota
            Get.to(() => MascotaDetailPage(mascota: mascota));
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Imagen de la mascota
                _buildMascotaAvatar(context, mascota),

                const SizedBox(width: 16),

                // Información de la mascota
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mascota.nombre ?? 'Sin nombre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildTipoBadge(context, mascota.tipo),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Detalles rápidos
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          if (mascota.raza != null)
                            _buildDetailChip(
                              context: context,
                              icon: Icons.science_outlined,
                              label: mascota.raza!,
                              color: context.colors.primary,
                            ),
                          if (mascota.edad != null)
                            _buildDetailChip(
                              context: context,
                              icon: Icons.cake_outlined,
                              label:
                                  '${mascota.edad} ${mascota.edadTiempo ?? 'años'}',
                              color: context.colors.secondary,
                            ),
                          if (mascota.tamano != null)
                            _buildDetailChip(
                              context: context,
                              icon: Icons.straighten,
                              label: _getTamanoText(mascota.tamano!),
                              color: context.colors.accent,
                            ),
                          if (mascota.peso != null)
                            _buildDetailChip(
                              context: context,
                              icon: Icons.fitness_center,
                              label: '${mascota.peso} kg',
                              color: context.colors.primary,
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Estado de salud
                      Row(
                        children: [
                          if (mascota.esterilizado)
                            _buildHealthBadge(
                              icon: Icons.medical_services,
                              label: 'Esterilizado',
                              color: context.colors.success,
                            ),
                          if (mascota.vacunado)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _buildHealthBadge(
                                icon: Icons.vaccines,
                                label: 'Vacunado',
                                color: context.colors.info,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Flecha de navegación
                Icon(
                  Icons.chevron_right,
                  color: context.colors.textTertiary,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMascotaAvatar(BuildContext context, MascotaModel mascota) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary.withOpacity(0.3),
            context.colors.secondary.withOpacity(0.3),
          ],
        ),
      ),
      child: ClipOval(
        child: mascota.imagenPrincipal != null
            ? Image.network(
                mascota.imagenPrincipal!,
                fit: BoxFit.cover,
                width: 70,
                height: 70,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar(context, mascota);
                },
              )
            : _buildDefaultAvatar(context, mascota),
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context, MascotaModel mascota) {
    return Container(
      color: context.colors.cardBackground,
      child: Center(
        child: Icon(
          mascota.tipo == 'perro'
              ? Icons.pets
              : mascota.tipo == 'gato'
              ? Icons.pets_rounded
              : Icons.pets_outlined,
          size: 35,
          color: context.colors.primary.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildTipoBadge(BuildContext context, String tipo) {
    Map<String, dynamic> tipoInfo = _getTipoInfo(context, tipo);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (tipoInfo['color'] as Color).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (tipoInfo['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tipoInfo['icon'] as String,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            tipoInfo['label'] as String,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: tipoInfo['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getTipoInfo(BuildContext context, String tipo) {
    switch (tipo.toLowerCase()) {
      case 'perro':
        return {
          'icon': '🐕',
          'label': 'Perro',
          'color': context.colors.primary,
        };
      case 'gato':
        return {
          'icon': '🐈',
          'label': 'Gato',
          'color': context.colors.secondary,
        };
      default:
        return {
          'icon': '🐾',
          'label': 'Mascota',
          'color': context.colors.accent,
        };
    }
  }

  Widget _buildDetailChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getTamanoText(String tamano) {
    switch (tamano.toLowerCase()) {
      case 'pequeño':
        return 'Pequeño';
      case 'mediano':
        return 'Mediano';
      case 'grande':
        return 'Grande';
      default:
        return tamano;
    }
  }

  Widget _buildPostsTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_outlined,
              size: 48,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tus publicaciones aparecerán aquí',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comparte tus experiencias con la comunidad',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    VoidCallback? onSeeAll,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: context.colors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
              ),
              child: Text(
                'Ver todas',
                style: TextStyle(
                  color: context.colors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================
  // LISTA HORIZONTAL DE MASCOTAS
  // =========================
  Widget _buildHorizontalPetsList(BuildContext context) {
    final controller = Get.find<MascotaController>();

    return Obx(() {
      if (controller.isLoading.value && controller.mascotas.isEmpty) {
        return Container(
          height: 150,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
            ),
          ),
        );
      }

      if (controller.mascotas.isEmpty) {
        return Container(
          height: 150,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 40, color: context.colors.textSecondary),
                const SizedBox(height: 8),
                Text(
                  'Aún no tienes mascotas',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navegar a registrar mascota
                    Get.to(() => const RegistrarMascotaPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Agregar mascota'),
                ),
              ],
            ),
          ),
        );
      }

      // 👈 Calcular cuántas mascotas mostrar (máximo 10)
      final maxItems = controller.mascotas.length > 10
          ? 10
          : controller.mascotas.length;
      // 👈 Mostrar el botón "+" solo si hay espacio (menos de 10 mascotas)
      final showAddButton = controller.mascotas.length < 10;

      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount:
              maxItems +
              (showAddButton ? 1 : 0), // 👈 +1 para el botón de agregar
          itemBuilder: (context, index) {
            // 👈 Si es el último y showAddButton es true, mostrar botón "+"
            if (showAddButton && index == maxItems) {
              return _buildAddPetCard(context);
            }

            // 👈 Si no, mostrar mascota
            final mascota = controller.mascotas[index];
            return _buildHorizontalPetCard(context, mascota);
          },
        ),
      );
    });
  }

  // =========================
  // TARJETA PARA AGREGAR MASCOTA
  // =========================
  Widget _buildAddPetCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegar a la página de creación de mascota
        Get.to(() => const RegistrarMascotaPage());
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.border,
            style: BorderStyle.solid,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colors.primary,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(Icons.add, size: 30, color: context.colors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Agregar mascota',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Registra una nueva',
              style: TextStyle(
                fontSize: 11,
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // TARJETA HORIZONTAL DE MASCOTA (con onTap)
  // =========================
  Widget _buildHorizontalPetCard(BuildContext context, dynamic mascota) {
    return GestureDetector(
      onTap: () {
        // Navegar al detalle de la mascota pasando el ID
        Get.to(() => MascotaDetailPage(mascota: mascota), arguments: mascota);
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen o avatar
            CircleAvatar(
              radius: 35,
              backgroundColor: context.colors.primary.withOpacity(0.1),
              backgroundImage: mascota.imagenPrincipal != null
                  ? NetworkImage(mascota.imagenPrincipal!)
                  : null,
              child: mascota.imagenPrincipal == null
                  ? Icon(Icons.pets, size: 30, color: context.colors.primary)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              mascota.nombre ?? 'Sin nombre',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              mascota.tipo ?? 'Mascota',
              style: TextStyle(
                fontSize: 11,
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(context, mascota.estadoActual),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getStatusLabel(mascota.estadoActual),
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // OBTENER COLOR DE ESTADO
  // =========================
  Color _getStatusColor(BuildContext context, String? estado) {
    switch (estado) {
      case 'activo':
        return context.colors.success;
      case 'pendiente':
        return context.colors.warning;
      case 'perdido':
        return context.colors.lost;
      case 'adoptado':
        return context.colors.found;
      case 'rechazado':
        return context.colors.error;
      default:
        return context.colors.textSecondary;
    }
  }

  // =========================
  // OBTENER ETIQUETA DE ESTADO
  // =========================
  String _getStatusLabel(String? estado) {
    switch (estado) {
      case 'activo':
        return 'Activo';
      case 'pendiente':
        return 'Pendiente';
      case 'perdido':
        return 'Perdido';
      case 'adoptado':
        return 'Adoptado';
      case 'rechazado':
        return 'Rechazado';
      default:
        return estado?.toUpperCase() ?? 'Activo';
    }
  }

  // =========================
  // TARJETA DE PUBLICACIÓN
  // =========================
  Widget _buildPostCard(BuildContext context, int index) {
    // Aquí iría tu lógica para obtener publicaciones
    // Por ahora un placeholder
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.colors.primary.withOpacity(0.2),
                child: Icon(Icons.person, color: context.colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuario', // Reemplazar con nombre real
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Text(
                      'Hace 2 horas', // Reemplazar con fecha real
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Contenido de la publicación',
            style: TextStyle(color: context.colors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 48,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.favorite_border, color: context.colors.textSecondary),
              const SizedBox(width: 4),
              Text('0', style: TextStyle(color: context.colors.textSecondary)),
              const SizedBox(width: 16),
              Icon(Icons.comment_outlined, color: context.colors.textSecondary),
              const SizedBox(width: 4),
              Text('0', style: TextStyle(color: context.colors.textSecondary)),
              const Spacer(),
              Icon(Icons.share_outlined, color: context.colors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // CONTADOR DE PUBLICACIONES (placeholder)
  // =========================
  int _getPostsCount() {
    // Reemplazar con el número real de publicaciones
    return 5; // Por ahora 5 publicaciones de ejemplo
  }
}
