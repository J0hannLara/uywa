import 'package:flutter/material.dart';
import 'package:mypets/core/theme/app_colors.dart';
import '../widgets/create_post_widget.dart';

class CreatePostModal extends StatelessWidget {
  const CreatePostModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: const CreatePostWidget(
        showCloseButton: true,
      ),
    );
  }
}