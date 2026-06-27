// lib/features/albergues/presentation/pages/mascota_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/albergues_controller.dart';

class MascotaListPage extends StatelessWidget {
  const MascotaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AlbergueController>();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          'Mascotas de ${controller.selectedAlbergue.value?.nombre ?? 'Albergue'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.mascotasAlbergue.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 80, color: context.colors.textSecondary.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'No hay mascotas registradas',
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.mascotasAlbergue.length,
          itemBuilder: (context, index) {
            final item = controller.mascotasAlbergue[index];
            final mascota = item['mascotas'] as Map<String, dynamic>?;
            
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
                  child: Icon(Icons.pets, color: context.colors.primary),
                ),
                title: Text(
                  mascota?['nombre'] ?? 'Sin nombre',
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                subtitle: Text(
                  'Ingresado: ${_formatDate(item['fecha_ingreso'])}',
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                trailing: Chip(
                  label: Text(item['estado'] ?? 'activo'),
                  backgroundColor: item['estado'] == 'activo'
                      ? context.colors.success.withOpacity(0.2)
                      : context.colors.warning.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: item['estado'] == 'activo' ? context.colors.success : context.colors.warning,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha desconocida';
    return '${date.day}/${date.month}/${date.year}';
  }
}