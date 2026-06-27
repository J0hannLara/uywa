import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Widget? fallbackIcon;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 40,
    this.onTap,
    this.backgroundColor,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? context.colors.primaryLight,
        backgroundImage: _getImageProvider(),
        child: _getChild(context),
      ),
    );
  }

  // 👈 Función para determinar el tipo de imagen
  ImageProvider? _getImageProvider() {
    if (imageUrl == null || imageUrl!.isEmpty) return null;

    // Si es URL de Google (empieza con http)
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return NetworkImage(imageUrl!);
    }
    
    // Si es asset (empieza con assets/)
    if (imageUrl!.startsWith('assets/')) {
      return AssetImage(imageUrl!);
    }

    // Si no coincide con ninguno, intentar como Network
    return NetworkImage(imageUrl!);
  }

  Widget? _getChild(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) return null;

    return fallbackIcon ?? Icon(
      Icons.person,
      size: radius * 0.8,
      color: context.colors.primary,
    );
  }
}