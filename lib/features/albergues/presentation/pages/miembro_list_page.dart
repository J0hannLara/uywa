// lib/features/albergues/presentation/pages/miembro_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/albergues_controller.dart';

class MiembroListPage extends StatelessWidget {
  const MiembroListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AlbergueController>();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          'Equipo de ${controller.selectedAlbergue.value?.nombre ?? 'Albergue'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Obx(() {
            final albergue = controller.selectedAlbergue.value;
            if (albergue != null && controller.esAdminDeAlbergue(albergue.id)) {
              return IconButton(
                icon: Icon(Icons.person_add, color: context.colors.primary),
                onPressed: () => _showAddMemberDialog(context, controller, albergue.id),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final miembros = controller.selectedAlbergue.value?.miembros ?? [];
        
        if (miembros.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 80, color: context.colors.textSecondary.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'No hay miembros registrados',
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: miembros.length,
          itemBuilder: (context, index) {
            final miembro = miembros[index];
            final isAdmin = controller.esAdminDeAlbergue(controller.selectedAlbergue.value!.id);
            
            return Card(
              elevation: 0,
              color: context.colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: context.colors.border),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.colors.primary.withOpacity(0.2),
                  child: Text(
                    miembro.rol[0].toUpperCase(),
                    style: TextStyle(color: context.colors.primary),
                  ),
                ),
                title: Text(
                  miembro.idUsuario,
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                subtitle: Text(
                  miembro.rol,
                  style: TextStyle(
                    color: miembro.rol == 'admin' ? context.colors.primary : context.colors.textSecondary,
                  ),
                ),
                trailing: isAdmin && miembro.rol != 'admin'
                    ? PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        color: context.colors.surface,
                        onSelected: (value) async {
                          if (value == 'remove') {
                            await controller.removerMiembroAlbergue(
                              albergueId: controller.selectedAlbergue.value!.id,
                              userId: miembro.idUsuario,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                         PopupMenuItem(
                            value: 'remove',
                            child: Text('Remover miembro', style: TextStyle(color: context.colors.error)),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      }),
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