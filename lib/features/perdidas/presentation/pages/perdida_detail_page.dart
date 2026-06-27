import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mypets/core/services/profile_avatar_service.dart';
import 'package:mypets/core/theme/app_colors.dart';
import 'package:mypets/features/mascotas/data/models/mascotas_model.dart';
import 'package:mypets/features/perdidas/presentation/widgets/perdida_map_widget.dart';
import '../controllers/perdidas_controller.dart';
import 'package:mypets/features/mascotas/presentation/pages/mascota_detail_page.dart';
import '../../data/models/perdidas_model.dart';

class PerdidaDetallePage extends StatelessWidget {
  const PerdidaDetallePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerdidaController>();
    final id = Get.arguments['id'] as int;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectPerdidaById(id);
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.selectedPerdida.value?.mascota?.nombre ??
                'Detalle de pérdida',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
        ),
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Obx(() {
            final perdida = controller.selectedPerdida.value;
            if (perdida == null || !perdida.estaActiva)
              return const SizedBox.shrink();

            return IconButton(
              icon: Icon(Icons.share_outlined, color: context.colors.primary),
              onPressed: () {
                // Compartir pérdida
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.selectedPerdida.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final perdida = controller.selectedPerdida.value;
        if (perdida == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets_outlined,
                  size: 64,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Pérdida no encontrada',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Volver'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainCard(context, perdida),

              const SizedBox(height: 16),

              // 👈 Convertir MascotaBasicaModel a MascotaModel
              if (perdida.mascota != null)
                _buildMascotaCard(
                  context,
                  _convertirBasicoAMascota(perdida.mascota!),
                ),

              const SizedBox(height: 16),

              if (perdida.mascota?.dueno != null)
                _buildDuenoCard(context, perdida.mascota!.dueno!),

              const SizedBox(height: 16),

              if (perdida.latitud != null && perdida.longitud != null)
                _buildMapCard(context, perdida),

              const SizedBox(height: 16),

              _buildHistorialCard(context, perdida),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  // 👈 Función de conversión
  MascotaModel _convertirBasicoAMascota(MascotaBasicaModel basico) {
    return MascotaModel(
      id: basico.id,
      nombre: basico.nombre,
      tipo: basico.tipo,
      raza: basico.raza,
      color: basico.color,
      imagenPrincipal: basico.imagenPrincipal,
      sexo: null,
      edad: null,
      edadTiempo: null,
      tamano: null,
      peso: null,
      esterilizado: false,
      vacunado: false,
      estadoActual: 'activo',
      microchip: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      descripcion: null,
      mascotaUsuarios: [],
      mascotaEstado: 'activo',
    );
  }

  Widget _buildMainCard(BuildContext context, PerdidaModel perdida) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(context, perdida.estado),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusLabel(perdida.estado),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(perdida.createdAt),
                style: TextStyle(
                  color: context.colors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            '📍 ${perdida.lugarPerdida}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Perdido el ${DateFormat('dd/MM/yyyy HH:mm').format(perdida.fechaPerdida)}',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                size: 16,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Radio de búsqueda: ${perdida.radioBusquedaKm} km',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          if (perdida.recompensa != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: context.colors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recompensa: Bs ${perdida.recompensa!.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: context.colors.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          if (perdida.descripcionPerdida != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Descripción',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              perdida.descripcionPerdida!,
              style: TextStyle(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],

          if (perdida.fueEncontrada) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.success.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: context.colors.success),
                      const SizedBox(width: 8),
                      Text(
                        '¡Encontrada!',
                        style: TextStyle(
                          color: context.colors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (perdida.detallesEncontrado != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      perdida.detallesEncontrado!,
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  ],
                  if (perdida.fechaEncontrado != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Encontrado el ${DateFormat('dd/MM/yyyy HH:mm').format(perdida.fechaEncontrado!)}',
                      style: TextStyle(
                        color: context.colors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMascotaCard(BuildContext context, MascotaModel mascota) {
    return GestureDetector(
      onTap: () {
        // 👈 Ahora pasamos un MascotaModel completo
        Get.to(() => MascotaDetailPage(mascota: mascota));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: mascota.imagenPrincipal != null
                  ? NetworkImage(mascota.imagenPrincipal!)
                  : null,
              backgroundColor: context.colors.primary.withOpacity(0.2),
              child: mascota.imagenPrincipal == null
                  ? Icon(Icons.pets, size: 30, color: context.colors.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mascota.nombre ?? 'Sin nombre',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mascota.tipo,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  if (mascota.raza != null)
                    Text(
                      mascota.raza!,
                      style: TextStyle(
                        color: context.colors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuenoCard(BuildContext context, DuenoBasicoModel dueno) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          ProfileAvatar(imageUrl: dueno.fotoPerfil, radius: 25),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dueno.nombre,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (dueno.telefono != null)
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 14,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dueno.telefono!,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                Text(
                  'Dueño de la mascota',
                  style: TextStyle(
                    color: context.colors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard(BuildContext context, PerdidaModel perdida) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ubicación',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                'Radio: ${perdida.radioBusquedaKm} km',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: PerdidaMapWidget(
              perdida: perdida,
              radiusKm: perdida.radioBusquedaKm.toDouble(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${perdida.latitud!.toStringAsFixed(6)}, ${perdida.longitud!.toStringAsFixed(6)}',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialCard(BuildContext context, PerdidaModel perdida) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildTimelineItem(
            context,
            icon: Icons.pets,
            title: 'Reporte de pérdida',
            description:
                'Creado el ${DateFormat('dd/MM/yyyy HH:mm').format(perdida.createdAt)}',
            isFirst: true,
          ),
          if (perdida.fueEncontrada)
            _buildTimelineItem(
              context,
              icon: Icons.check_circle,
              title: 'Mascota encontrada',
              description: perdida.fechaEncontrado != null
                  ? 'Encontrado el ${DateFormat('dd/MM/yyyy HH:mm').format(perdida.fechaEncontrado!)}'
                  : 'Reportada como encontrada',
              color: context.colors.success,
            ),
          if (perdida.estaCerrada)
            _buildTimelineItem(
              context,
              icon: Icons.lock,
              title: 'Caso cerrado',
              description: 'El caso ha sido cerrado',
              color: context.colors.textSecondary,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    bool isFirst = false,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (color ?? context.colors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color ?? context.colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
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
  }

  Color _getStatusColor(BuildContext context, String estado) {
    switch (estado) {
      case 'activa':
        return context.colors.lost;
      case 'encontrada':
        return context.colors.success;
      case 'cerrada':
        return context.colors.textSecondary;
      default:
        return context.colors.textSecondary;
    }
  }

  String _getStatusLabel(String estado) {
    switch (estado) {
      case 'activa':
        return 'ACTIVA';
      case 'encontrada':
        return 'ENCONTRADA';
      case 'cerrada':
        return 'CERRADA';
      default:
        return estado.toUpperCase();
    }
  }
}
