import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/mascotas_controller.dart';
import 'package:mypets/features/perfiles/presentation/controllers/perfiles_controller.dart';

class MascotaFormWidget extends StatefulWidget {
  const MascotaFormWidget({super.key});

  @override
  State<MascotaFormWidget> createState() => _MascotaFormWidgetState();
}

class _MascotaFormWidgetState extends State<MascotaFormWidget>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<MascotaController>();
  final controllerProfile = Get.find<ProfileController>();

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final razaController = TextEditingController();
  final colorController = TextEditingController();
  final edadController = TextEditingController();
  final pesoController = TextEditingController();
  final microchipController = TextEditingController();

  String tipo = 'perro';
  String sexo = 'macho';
  String edadTiempo = 'años';
  String tamano = 'mediano';
  bool esterilizado = false;
  bool vacunado = false;
  File? imagen;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      imagen = File(picked.path);
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    razaController.dispose();
    colorController.dispose();
    edadController.dispose();
    pesoController.dispose();
    microchipController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: context.colors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Registra a tu mascota',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completa los datos de tu compañero',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Indicador de progreso (como paso 3)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Registro de mascota',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Información completa',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: context.colors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colors.primary,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Card del formulario
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar de mascota
                        Center(
                          child: GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.colors.primary.withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: context.colors.cardBackground,
                                    backgroundImage: imagen != null
                                        ? FileImage(imagen!)
                                        : null,
                                    child: imagen == null
                                        ? Icon(
                                            Icons.camera_alt,
                                            size: 40,
                                            color: context.colors.textSecondary,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: context.colors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: context.colors.background,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Toca para añadir foto',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textTertiary,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Nombre
                        _buildInputField(
                          context: context,
                          controller: nombreController,
                          label: 'Nombre de tu mascota',
                          hint: 'Ej: Luna, Max, Simba',
                          icon: Icons.pets,
                          prefixIconColor: context.colors.primary,
                        ),

                        const SizedBox(height: 20),

                        // Tipo y Sexo en fila
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                value: tipo,
                                label: 'Tipo',
                                icon: Icons.category,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'perro',
                                    child: Text('🐕 Perro'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'gato',
                                    child: Text('🐈 Gato'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'otro',
                                    child: Text('🐾 Otro'),
                                  ),
                                ],
                                onChanged: (v) => setState(() => tipo = v!),
                                prefixIconColor: context.colors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdownField(
                                value: sexo,
                                label: 'Sexo',
                                icon: Icons.wc,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'macho',
                                    child: Text('♂️ Macho'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'hembra',
                                    child: Text('♀️ Hembra'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'desconocido',
                                    child: Text('❓ Otro'),
                                  ),
                                ],
                                onChanged: (v) => setState(() => sexo = v!),
                                prefixIconColor: context.colors.secondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Raza y Color
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                context: context,
                                controller: razaController,
                                label: 'Raza',
                                hint: 'Ej: Golden Retriever',
                                icon: Icons.science,
                                prefixIconColor: context.colors.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                context: context,
                                controller: colorController,
                                label: 'Color',
                                hint: 'Ej: Dorado',
                                icon: Icons.color_lens,
                                prefixIconColor: context.colors.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Edad y Tamaño
                        Row(
                          children: [
                            Expanded(
                              child: _buildNumberField(
                                controller: edadController,
                                label: 'Edad',
                                hint: '0',
                                icon: Icons.cake,
                                prefixIconColor: context.colors.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdownField(
                                value: edadTiempo,
                                label: 'Unidad',
                                icon: Icons.timer,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'dias',
                                    child: Text('Días'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'meses',
                                    child: Text('Meses'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'años',
                                    child: Text('Años'),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => edadTiempo = v!),
                                prefixIconColor: context.colors.accent,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Tamaño y Peso
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                value: tamano,
                                label: 'Tamaño',
                                icon: Icons.straighten,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'pequeño',
                                    child: Text('🐭 Pequeño'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'mediano',
                                    child: Text('🐕 Mediano'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'grande',
                                    child: Text('🐘 Grande'),
                                  ),
                                ],
                                onChanged: (v) => setState(() => tamano = v!),
                                prefixIconColor: context.colors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildNumberField(
                                controller: pesoController,
                                label: 'Peso (kg)',
                                hint: '0.0',
                                icon: Icons.fitness_center,
                                prefixIconColor: context.colors.secondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Descripción
                        _buildInputField(
                          context: context,
                          controller: descripcionController,
                          label: 'Descripción',
                          hint:
                              'Cuéntanos sobre su personalidad, historia, etc.',
                          icon: Icons.description_outlined,
                          prefixIconColor: context.colors.accent,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 24),

                        // Separador
                        Container(
                          height: 1,
                          color: context.colors.border,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                        ),

                        const SizedBox(height: 8),

                        // Sección de salud
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.colors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.health_and_safety,
                                color: context.colors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Salud y cuidados',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Switches
                        _buildSwitchTile(
                          value: esterilizado,
                          title: 'Esterilizado / Castrado',
                          subtitle: 'Ayuda al control de la población animal',
                          icon: Icons.medical_services,
                          color: context.colors.primary,
                          onChanged: (v) => setState(() => esterilizado = v),
                        ),

                        _buildSwitchTile(
                          value: vacunado,
                          title: 'Vacunado',
                          subtitle: 'Cuenta con su esquema de vacunación',
                          icon: Icons.vaccines,
                          color: context.colors.secondary,
                          onChanged: (v) => setState(() => vacunado = v),
                        ),

                        // Campo opcional de microchip
                        if (microchipController.text.isNotEmpty ||
                            microchipController.text == 'null')
                          const SizedBox(height: 16),

                        if (microchipController.text.isNotEmpty ||
                            microchipController.text == 'null')
                          _buildInputField(
                            context: context,
                            controller: microchipController,
                            label: 'Número de microchip',
                            hint: 'Opcional',
                            icon: Icons.qr_code_scanner,
                            prefixIconColor: context.colors.accent,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botón Guardar
                Obx(() {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              await controller.createMascota(
                                nombre: nombreController.text,
                                descripcion: descripcionController.text,
                                tipo: tipo,
                                sexo: sexo,
                                raza: razaController.text,
                                color: colorController.text,
                                edad: int.tryParse(edadController.text),
                                edadTiempo: edadTiempo,
                                tamano: tamano,
                                peso: double.tryParse(pesoController.text),
                                esterilizado: esterilizado,
                                vacunado: vacunado,
                                microchip: microchipController.text.isNotEmpty
                                    ? microchipController.text
                                    : 'null',
                                imagen: imagen,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Registrar mascota',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.save_alt_rounded, size: 20),
                              ],
                            ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Texto de ayuda
                Center(
                  child: Text(
                    'Los datos de tu mascota serán parte de su perfil público',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Color? prefixIconColor,
    int maxLines = 1,
  }) {
    final color = prefixIconColor ?? context.colors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: context.colors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.colors.textTertiary, fontSize: 14),
            prefixIcon: Icon(icon, color: prefixIconColor, size: 22),
            filled: true,
            fillColor: context.colors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.colors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    Color? prefixIconColor,
  }) {
    final color = prefixIconColor ?? context.colors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: context.colors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.colors.textTertiary, fontSize: 14),
            prefixIcon: Icon(icon, color: prefixIconColor, size: 22),
            filled: true,
            fillColor: context.colors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.colors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    Color? prefixIconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.colors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              dropdownColor: context.colors.surface,
              style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
              icon: Icon(Icons.arrow_drop_down, color: prefixIconColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required bool value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: context.colors.textTertiary),
        ),
        activeColor: color,
        activeTrackColor: color.withOpacity(0.3),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
