import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypets/core/theme/app_colors.dart';
import 'package:mypets/features/publicaciones/presentation/controllers/publicaciones_controller.dart';
import 'package:mypets/features/publicaciones/presentation/widgets/publicaciones_card.dart';

class FeedWidget extends StatelessWidget {
  const FeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PublicacionController>();

    return Obx(() {
      if (controller.isLoadingFeed.value && controller.feedGlobal.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
              ),
              SizedBox(height: 16),
              Text(
                'Cargando publicaciones...',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ],
          ),
        );
      }

      if (controller.feedGlobal.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 64,
                color: context.colors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay publicaciones aún',
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sé el primero en publicar',
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshFeed(),
        color: context.colors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: controller.feedGlobal.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.feedGlobal.length) {
              if (controller.isLoadingFeed.value) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
                    ),
                  ),
                );
              }
              if (controller.hayMasFeed.value) {
                controller.cargarMasFeed();
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '✨ No hay más publicaciones ✨',
                    style: TextStyle(
                      color: context.colors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }

            final post = controller.feedGlobal[index];
            return PostCard(
              post: post,
              onTap: () {
                // Navegar a detalle
                controller.selectPublicacion(post.id);
              },
            );
          },
        ),
      );
    });
  }
}