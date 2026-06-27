import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypets/features/publicaciones/presentation/pages/create_post_modal.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../publicaciones/presentation/controllers/publicaciones_controller.dart';
import '../../../publicaciones/presentation/widgets/publicaciones_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PublicacionController controller = Get.find<PublicacionController>();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/logosf.png',
                width: 32,
                height: 32,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'UYWA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: context.colors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: context.colors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshFeed();
        },
        child: Obx(() {
          if (controller.isLoadingFeed.value && controller.feedGlobal.isEmpty) {
            return _buildShimmerLoading();
          }

          if (controller.feedGlobal.isEmpty &&
              !controller.isLoadingFeed.value) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            controller: ScrollController(),
            itemCount: controller.feedGlobal.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.feedGlobal.length) {
                if (controller.hayMasFeed.value) {
                  controller.cargarMasFeed();
                  return _buildLoadingMore();
                }
                return const SizedBox.shrink();
              }
              return PostCard(post: controller.feedGlobal[index]);
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostModal()),
          );
          if (result == true) {
            controller.refreshFeed();
          }
        },
        backgroundColor: context.colors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Publicar'),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 400,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets_outlined, size: 80, color: context.colors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No hay publicaciones aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sigue a más personas o crea tu primera publicación',
            style: TextStyle(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Get.to(() => const CreatePostModal());
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear publicación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
