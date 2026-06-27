// lib/features/publicaciones/presentation/widgets/create_post_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../controllers/publicaciones_controller.dart';

class CreatePostWidget extends StatefulWidget {
  final VoidCallback? onPostCreated;
  final bool showCloseButton;

  const CreatePostWidget({
    super.key,
    this.onPostCreated,
    this.showCloseButton = false,
  });

  @override
  State<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  List<File> _images = [];
  final _imagePicker = ImagePicker();
  bool _isSubmitting = false;
  bool _showLocation = false;

  @override
  Widget build(BuildContext context) {
    final PublicacionController controller = Get.find<PublicacionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y botón de cerrar (opcional)
            if (widget.showCloseButton)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nueva Publicación',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: context.colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Botón Publicar (para versión sin AppBar)
            const SizedBox(height: 20),

            // Sección de imágenes
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: context.colors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Fotos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (_images.isNotEmpty)
                          Text(
                            '${_images.length}/10',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildImageGrid(),
                  if (_images.isNotEmpty && _images.length < 10)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: context.colors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.colors.border),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: context.colors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Agregar más fotos',
                                  style: TextStyle(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Descripción
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: context.colors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      style: TextStyle(color: context.colors.textPrimary, fontSize: 16),
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: '¿Qué quieres compartir?',
                        hintStyle: TextStyle(
                          color: context.colors.textSecondary.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: 6,
                      minLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una descripción';
                        }
                        if (value.length < 5) {
                          return 'La descripción debe tener al menos 5 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Ubicación opcional
            Card(
              elevation: 0,
              color: context.colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: context.colors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: context.colors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Agregar ubicación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Comparte dónde fue tomada la foto',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    value: _showLocation,
                    onChanged: (value) {
                      setState(() {
                        _showLocation = value;
                        if (!value) {
                          _locationController.clear();
                        }
                      });
                    },
                    activeColor: context.colors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  if (_showLocation)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        style: TextStyle(color: context.colors.textPrimary, fontSize: 16),
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Ej: Parque de las Aguas, Cochabamba',
                          prefixIcon: Icon(
                            Icons.location_pin,
                            color: context.colors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: context.colors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: context.colors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: context.colors.primary),
                          ),
                          filled: true,
                          fillColor: context.colors.background,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Vista previa
            if (_descriptionController.text.isNotEmpty || _images.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.preview, size: 20, color: context.colors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Vista previa',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_images.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _images.first,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _descriptionController.text.isEmpty
                          ? 'Descripción de la publicación'
                          : _descriptionController.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSubmitting.value || _isSubmitting
                        ? null
                        : () => _submitPost(controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSubmitting.value || _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Publicar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    if (_images.isEmpty) {
      return InkWell(
        onTap: _pickImage,
        child: Container(
          height: 200,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 64,
                color: context.colors.primary.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'Toca para agregar fotos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Máximo 10 fotos',
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _images.length.clamp(0, 9),
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_images[index], fit: BoxFit.cover),
            ),
            if (index == 0 && _images.length > 1)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${_images.length - 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _images.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      if (_images.length < 10) {
        setState(() {
          _images.add(File(image.path));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Máximo 10 fotos permitidas')),
        );
      }
    }
  }

  void _submitPost(PublicacionController controller) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa la descripción')),
      );
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor agrega al menos una foto')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await controller.createPublicacion(
      tipoPublicacion: 'post',
      titulo: 'publicacion',
      descripcion: _descriptionController.text,
      ubicacionTexto: _showLocation ? _locationController.text : null,
      imagenes: _images,
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
