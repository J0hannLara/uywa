import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mypets/features/perdidas/presentation/pages/perdida_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/profile_avatar_service.dart';
import '../../data/models/publicaciones_model.dart';
import '../controllers/publicaciones_controller.dart';

class PostCard extends StatefulWidget {
  final PublicacionModel post;
  final VoidCallback? onTap;

  const PostCard({super.key, required this.post, this.onTap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PublicacionController _controller = Get.find<PublicacionController>();
  bool isLiked = false;
  int likeCount = 0;
  int shareCount = 0;
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    // Aquí puedes cargar los contadores reales desde tu API si los tienes
    likeCount = widget.post.visualizaciones; // Temporal, ajusta según tu modelo
    shareCount = widget.post.compartidos;
    commentCount = 0; // Si tienes comentarios en tu modelo, ajústalo
  }

  String _getTipoText() {
    switch (widget.post.tipoPublicacion.toLowerCase()) {
      case 'perdido':
        return 'Perdido/a';
      case 'encontrado':
        return 'Encontrado/a';
      case 'adopcion':
        return 'En adopción';
      case 'rescatado':
        return 'Rescatado/a';
      case 'exitoso':
        return 'Caso de éxito';
      default:
        return widget.post.tipoPublicacion;
    }
  }

  Color _getTipoColor() {
    switch (widget.post.tipoPublicacion.toLowerCase()) {
      case 'perdido':
        return context.colors.lost;
      case 'encontrado':
        return context.colors.found;
      case 'adopcion':
        return context.colors.adoption;
      case 'rescatado':
        return context.colors.rescued;
      case 'exitoso':
        return context.colors.success;
      default:
        return context.colors.primary;
    }
  }

  IconData _getTipoIcon() {
    switch (widget.post.tipoPublicacion.toLowerCase()) {
      case 'perdido':
        return Icons.pets_outlined;
      case 'encontrado':
        return Icons.favorite_outline;
      case 'adopcion':
        return Icons.home_outlined;
      case 'rescatado':
        return Icons.medical_services_outlined;
      case 'exitoso':
        return Icons.emoji_events_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  bool get isUrgent {
    return widget.post.tipoPublicacion.toLowerCase() == 'perdido';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
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
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Avatar del usuario (puedes obtenerlo de otro lugar)
                  ProfileAvatar(
                    imageUrl: widget.post.usuario?.fotoPerfil,
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.post.usuario?.username ??
                                  'Usuario', // Temporal, idealmente traer nombre
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (widget.post.ubicacionTexto != null) ...[
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: context.colors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.post.ubicacionTexto!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: context.colors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat(
                                'HH:mm • dd/MM',
                              ).format(widget.post.createdAt),
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
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.colors.lost.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: context.colors.lost,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Imágenes (si tiene)
            if (widget.post.imagenes.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: widget.post.imagenes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.post.imagenes[index].url,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: context.colors.cardBackground,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: context.colors.primary,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: context.colors.cardBackground,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: context.colors.textTertiary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (widget.post.imagenes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: context.colors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 50,
                          color: context.colors.textTertiary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sin imagen',
                          style: TextStyle(
                            color: context.colors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Descripción
            if (widget.post.descripcion != null &&
                widget.post.descripcion!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  widget.post.descripcion!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: context.colors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 12),

            // Stats (visualizaciones y compartidos)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildStatButton(
                    icon: Icons.visibility_outlined,
                    count: widget.post.visualizaciones,
                    color: context.colors.textSecondary,
                    onTap: () {},
                  ),
                  const SizedBox(width: 24),
                  _buildStatButton(
                    icon: Icons.share_outlined,
                    count: shareCount,
                    color: context.colors.textSecondary,
                    onTap: () {
                      setState(() {
                        shareCount++;
                      });
                      // Aquí llamarías a la función de compartir
                    },
                  ),
                  const Spacer(),
                  // Botón de like (si implementas en el futuro)
                  _buildStatButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    count: likeCount,
                    color: isLiked
                        ? context.colors.like
                        : context.colors.textSecondary,
                    onTap: () {
                      setState(() {
                        isLiked = !isLiked;
                        likeCount += isLiked ? 1 : -1;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Botón de acción según el tipo
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () {
                  _navigateByType(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getTipoColor(),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _getButtonText(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  void _navigateByType(BuildContext context) {
    final tipo = widget.post.tipoPublicacion.toLowerCase();

    switch (tipo) {
      case 'perdido':
        // 👈 Usar id_referencia directamente
        if (widget.post.idReferencia != null) {
          Get.to(
            () => const PerdidaDetallePage(),
            arguments: {'id': widget.post.idReferencia},
          );
        } else {
          // Fallback: buscar por publicación (solo si id_referencia es null)
          _buscarPerdidaPorPublicacion(widget.post.id);
        }
        break;

      case 'adopcion':
        Get.toNamed('/adopcion/detalle', arguments: {'id': widget.post.id});
        break;

      case 'encontrado':
        Get.toNamed('/encontrado/detalle', arguments: {'id': widget.post.id});
        break;

      case 'rescate':
        Get.toNamed('/rescate/detalle', arguments: {'id': widget.post.id});
        break;

      default:
        Get.toNamed('/publicacion/detalle', arguments: {'id': widget.post.id});
    }
  }

  // =========================
  // BUSCAR PÉRDIDA POR PUBLICACIÓN
  // =========================
  void _buscarPerdidaPorPublicacion(int publicacionId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('perdidas')
          .select('id')
          .eq('id_publicacion', publicacionId)
          .maybeSingle();

      if (response != null) {
        final perdidaId = response['id'] as int;
        Get.to(() => const PerdidaDetallePage(), arguments: {'id': perdidaId});
      } else {
        Get.snackbar('Error', 'No se encontró el detalle de la pérdida');
      }
    } catch (e) {
      print('Error buscando pérdida: $e');
      Get.snackbar('Error', 'No se pudo cargar el detalle');
    }
  }

  Widget _buildStatButton({
    required IconData icon,
    required int count,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? context.colors.textSecondary),
          const SizedBox(width: 6),
          Text(
            _formatCount(count),
            style: TextStyle(
              fontSize: 12,
              color: color ?? context.colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    switch (widget.post.tipoPublicacion.toLowerCase()) {
      case 'perdido':
        return 'AYUDAR A BUSCAR';
      case 'encontrado':
        return 'CONTACTAR';
      case 'adopcion':
        return 'QUIERO ADOPTAR';
      case 'rescatado':
        return 'APADRINAR';
      case 'exitoso':
        return 'VER HISTORIA';
      default:
        return 'MÁS INFORMACIÓN';
    }
  }

  void _showActionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: context.colors.surface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Cómo quieres ayudar?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.share, color: context.colors.primary),
              ),
              title: Text(
                'Compartir publicación',
                style: TextStyle(color: context.colors.textPrimary),
              ),
              subtitle: Text(
                'Ayuda a llegar a más personas',
                style: TextStyle(color: context.colors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implementar compartir
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.message, color: context.colors.secondary),
              ),
              title: Text(
                'Contactar al usuario',
                style: TextStyle(color: context.colors.textPrimary),
              ),
              subtitle: Text(
                'Ofrece información o ayuda',
                style: TextStyle(color: context.colors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implementar contacto
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
