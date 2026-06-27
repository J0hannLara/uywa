import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/create_post_widget.dart';

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          'Nueva Publicación',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        backgroundColor: context.colors.cardBackground,
        elevation: 0,
      ),
      body: const CreatePostWidget(showCloseButton: false),
    );
  }
}
