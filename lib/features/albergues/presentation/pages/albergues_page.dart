// lib/features/albergues/presentation/pages/albergues_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/albergues_controller.dart';
import 'albergue_detail_page.dart';

class AlberguesPage extends StatelessWidget {
  const AlberguesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AlbergueController>();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          'Albergues Verificados',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        backgroundColor: context.colors.cardBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: context.colors.primary),
            onPressed: () => _showSearchDialog(context, controller),
          ),
          Obx(
            () => Badge(
              label: Text(
                controller.filtroBusqueda.value.isNotEmpty ? '1' : '',
              ),
              child: IconButton(
                icon: Icon(Icons.filter_list, color: context.colors.primary),
                onPressed: () => _showFilterDialog(context, controller),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.alberguesPublicos.isEmpty) {
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
                  'Cargando albergues...',
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              ],
            ),
          );
        }

        if (controller.alberguesFiltrados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.surface,
                  ),
                  child: Icon(
                    Icons.pets,
                    size: 50,
                    color: context.colors.textSecondary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No hay albergues disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.filtroBusqueda.value.isNotEmpty
                      ? 'No se encontraron albergues con ese filtro'
                      : 'Pronto habrá más albergues disponibles',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                  ),
                ),
                if (controller.filtroBusqueda.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextButton.icon(
                      onPressed: () => controller.filtroBusqueda.value = '',
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpiar filtros'),
                      style: TextButton.styleFrom(
                        foregroundColor: context.colors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshAlberguesPublicos,
          color: context.colors.primary,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (!controller.isLoadingMore.value &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent &&
                  controller.hayMasPublicos.value) {
                controller.cargarMasPublicos();
              }
              return true;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.alberguesFiltrados.length + 1,
              itemBuilder: (context, index) {
                if (index == controller.alberguesFiltrados.length) {
                  if (controller.isLoadingMore.value) {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.colors.primary,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final albergue = controller.alberguesFiltrados[index];
                return _buildShelterCard(
                      context: context,
                      albergue: albergue,
                      onTap: () {
                        controller.loadAlbergueById(albergue.id);
                        Get.to(() => const AlbergueDetailPage());
                      },
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(
                      begin: 0.1,
                      duration: 300.ms,
                      delay: Duration(milliseconds: index * 50),
                    );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShelterCard({
    required BuildContext context,
    required dynamic albergue,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.colors.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 80,
                  height: 80,
                  color: context.colors.cardBackground,
                  child: albergue.imagen != null
                      ? Image.network(
                          albergue.imagen,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.pets,
                              size: 40,
                              color: context.colors.primary.withOpacity(0.5),
                            );
                          },
                        )
                      : Icon(
                          Icons.pets,
                          size: 40,
                          color: context.colors.primary.withOpacity(0.5),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            albergue.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: context.colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (albergue.verificado)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 10,
                                  color: context.colors.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Verif.',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (albergue.ubicacion != null)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: context.colors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              albergue.ubicacion!,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.colors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 12,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${albergue.mascotas.length} mascotas',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.people,
                          size: 12,
                          color: context.colors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${albergue.miembros.length} miembros',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botón Ver
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(60, 36),
                ),
                child: const Text('Ver', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, AlbergueController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Buscar albergue',
          style: TextStyle(color: context.colors.textPrimary),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: context.colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Nombre o ubicación',
            hintStyle: TextStyle(color: context.colors.textTertiary),
            prefixIcon: Icon(Icons.search, color: context.colors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: context.colors.cardBackground,
          ),
          onChanged: (value) {
            controller.filtroBusqueda.value = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Aplicar',
              style: TextStyle(color: context.colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, AlbergueController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: context.colors.surface,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Text(
                    'Filtrar albergues',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                 Text(
                    'Próximamente más filtros',
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
