// lib/features/albergues/presentation/pages/albergue_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/albergues_controller.dart';
import 'mascota_list_page.dart';

class AlbergueDetailPage extends StatelessWidget {
  const AlbergueDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AlbergueController>();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.selectedAlbergue.value?.nombre ?? 'Albergue',
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Obx(() {
            final albergue = controller.selectedAlbergue.value;
            final isAdmin = albergue != null && controller.esAdminDeAlbergue(albergue.id);
            
            if (isAdmin) {
              return IconButton(
                icon: Icon(Icons.edit, color: context.colors.primary),
                onPressed: () => _showEditDialog(context, controller, albergue),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.selectedAlbergue.value == null) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
            ),
          );
        }

        final albergue = controller.selectedAlbergue.value;
        if (albergue == null) {
          return Center(
            child: Text(
              'Albergue no encontrado',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de portada
              _buildCoverImage(context, albergue.imagen),
              
              // Información principal
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y verificación
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            albergue.nombre,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        if (albergue.verificado)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.verified, size: 14, color: context.colors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Verificado',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Ubicación
                    if (albergue.ubicacion != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: context.colors.secondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                albergue.ubicacion!,
                                style: TextStyle(color: context.colors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Contacto
                    if (albergue.telefono != null || albergue.email != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            if (albergue.telefono != null)
                              ListTile(
                                leading: Icon(Icons.phone, color: context.colors.primary),
                                title: Text(albergue.telefono!, style: TextStyle(color: context.colors.textPrimary)),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                onTap: () {
                                  // Implementar llamada
                                },
                              ),
                            if (albergue.email != null)
                              ListTile(
                                leading: Icon(Icons.email, color: context.colors.secondary),
                                title: Text(albergue.email!, style: TextStyle(color: context.colors.textPrimary)),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                onTap: () {
                                  // Implementar email
                                },
                              ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Descripción
                    if (albergue.descripcion != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sobre nosotros',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              albergue.descripcion!,
                              style: TextStyle(color: context.colors.textSecondary, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Estadísticas
                    Row(
                      children: [
                        _buildStatCard(context, 
                          icon: Icons.pets,
                          label: 'Mascotas',
                          value: albergue.mascotas.length.toString(),
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(context,
                          icon: Icons.people,
                          label: 'Miembros',
                          value: albergue.miembros.length.toString(),
                          color: context.colors.secondary,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Sección de mascotas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mascotas en el albergue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Get.to(() => const MascotaListPage());
                          },
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Ver todas'),
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMascotasPreview(context, albergue.mascotas),
                    
                    const SizedBox(height: 24),
                    
                    // Sección de miembros
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Miembros del equipo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        if (controller.esAdminDeAlbergue(albergue.id))
                          TextButton.icon(
                            onPressed: () {
                              _showAddMemberDialog(context, controller, albergue.id);
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Agregar'),
                            style: TextButton.styleFrom(
                              foregroundColor: context.colors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMiembrosList(context, albergue.miembros, albergue.id),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCoverImage(BuildContext context, String? imageUrl) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: context.colors.primaryGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(Icons.pets, size: 80, color: Colors.white.withOpacity(0.5)),
                  );
                },
              ),
            )
          : Center(
              child: Icon(Icons.pets, size: 80, color: Colors.white.withOpacity(0.5)),
            ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotasPreview(BuildContext context, List<dynamic> mascotas) {
    if (mascotas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No hay mascotas registradas',
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mascotas.length > 5 ? 5 : mascotas.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final mascota = mascotas[index];
          return Container(
            width: 100,
            decoration: BoxDecoration(
              color: context.colors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: context.colors.primary.withOpacity(0.2),
                  child: Icon(Icons.pets, color: context.colors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  mascota.mascota?.nombre ?? 'Sin nombre',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiembrosList(BuildContext context, List<dynamic> miembros, int albergueId) {
    if (miembros.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No hay miembros registrados',
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: miembros.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final miembro = miembros[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.colors.primary.withOpacity(0.2),
                child: Text(
                  miembro.rol[0].toUpperCase(),
                  style: TextStyle(color: context.colors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      miembro.idUsuario,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Text(
                      miembro.rol,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, AlbergueController controller, dynamic albergue) {
    final nombreController = TextEditingController(text: albergue.nombre);
    final descripcionController = TextEditingController(text: albergue.descripcion ?? '');
    final telefonoController = TextEditingController(text: albergue.telefono ?? '');
    final emailController = TextEditingController(text: albergue.email ?? '');
    final ubicacionController = TextEditingController(text: albergue.ubicacion ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Editar albergue', style: TextStyle(color: context.colors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: context.colors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descripcionController,
                style: TextStyle(color: context.colors.textPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: context.colors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: telefonoController,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  labelStyle: TextStyle(color: context.colors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: context.colors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ubicacionController,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Ubicación',
                  labelStyle: TextStyle(color: context.colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: context.colors.textSecondary)),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isSubmitting.value
                ? null
                : () async {
                    await controller.updateAlbergueInfo(
                      id: albergue.id,
                      data: {
                        'nombre': nombreController.text,
                        'descripcion': descripcionController.text,
                        'telefono': telefonoController.text,
                        'email': emailController.text,
                        'ubicacion': ubicacionController.text,
                      },
                    );
                    if (Get.isSnackbarOpen == false) {
                      Navigator.pop(context);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: controller.isSubmitting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Guardar'),
          )),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, AlbergueController controller, int albergueId) {
    final userIdController = TextEditingController();
    String selectedRol = 'voluntario';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Agregar miembro', style: TextStyle(color: context.colors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(
                labelText: 'ID de usuario',
                labelStyle: TextStyle(color: context.colors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedRol,
              dropdownColor: context.colors.surface,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Rol',
                labelStyle: TextStyle(color: context.colors.textSecondary),
              ),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                DropdownMenuItem(value: 'voluntario', child: Text('Voluntario')),
                DropdownMenuItem(value: 'veterinario', child: Text('Veterinario')),
              ],
              onChanged: (value) {
                if (value != null) selectedRol = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: context.colors.textSecondary)),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isSubmitting.value
                ? null
                : () async {
                    await controller.agregarMiembroAlbergue(
                      albergueId: albergueId,
                      userId: userIdController.text,
                      rol: selectedRol,
                    );
                    if (Get.isSnackbarOpen == false) {
                      Navigator.pop(context);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: controller.isSubmitting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Agregar'),
          )),
        ],
      ),
    );
  }
}