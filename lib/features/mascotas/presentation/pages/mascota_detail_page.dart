import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypets/core/services/profile_avatar_service.dart';
import 'package:mypets/features/auth/data/models/usuario_model.dart';
import 'package:mypets/features/perdidas/presentation/pages/reportar_perdida_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/mascotas_model.dart';
import '../controllers/mascotas_controller.dart';

class MascotaDetailPage extends StatefulWidget {
  final MascotaModel mascota;

  const MascotaDetailPage({super.key, required this.mascota});

  @override
  State<MascotaDetailPage> createState() => _MascotaDetailPageState();
}

class _MascotaDetailPageState extends State<MascotaDetailPage> {
  late MascotaModel _mascota;
  bool _isEditing = false;

  // Controladores para edición
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _razaController;
  late TextEditingController _colorController;
  late TextEditingController _edadController;
  late TextEditingController _pesoController;
  late TextEditingController _microchipController;

  String? _selectedSexo;
  String? _selectedTamano;
  String? _selectedEdadTiempo;
  bool _esterilizado = false;
  bool _vacunado = false;

  final MascotaController _controller = Get.find<MascotaController>();

  @override
  void initState() {
    super.initState();
    _mascota = widget.mascota;
    _initControllers();
  }

  void _initControllers() {
    _nombreController = TextEditingController(text: _mascota.nombre ?? '');
    _descripcionController = TextEditingController(
      text: _mascota.descripcion ?? '',
    );
    _razaController = TextEditingController(text: _mascota.raza ?? '');
    _colorController = TextEditingController(text: _mascota.color ?? '');
    _edadController = TextEditingController(
      text: _mascota.edad?.toString() ?? '',
    );
    _pesoController = TextEditingController(
      text: _mascota.peso?.toString() ?? '',
    );
    _microchipController = TextEditingController(
      text: _mascota.microchip ?? '',
    );

    _selectedSexo = _mascota.sexo;
    _selectedTamano = _mascota.tamano;
    _selectedEdadTiempo = _mascota.edadTiempo;
    _esterilizado = _mascota.esterilizado;
    _vacunado = _mascota.vacunado;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _razaController.dispose();
    _colorController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    _microchipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el usuario dueño (el primero con rol 'dueno')
    final dueno = _mascota.dueno;
    final duenoInfo = _mascota.duenoInfo;

    if (dueno == null || duenoInfo == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          _mascota.nombre ?? 'Mi mascota',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        backgroundColor: context.colors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: context.colors.primary,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _initControllers(); // Resetear cambios
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de portada
            _buildCoverImage(context),

            // Información principal
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y estado
                  Row(
                    children: [
                      Expanded(
                        child: _isEditing
                            ? TextFormField(
                                controller: _nombreController,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Nombre',
                                  hintStyle: TextStyle(
                                    color: context.colors.textTertiary,
                                  ),
                                ),
                              )
                            : Text(
                                _mascota.nombre ?? 'Sin nombre',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                      ),
                      _buildStatusChip(context),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Información del dueño
                  if (dueno != null) _buildOwnerInfo(context, duenoInfo, dueno),

                  const SizedBox(height: 20),

                  // Detalles de la mascota
                  _buildDetailsSection(context),

                  const SizedBox(height: 24),

                  // Botones de acción
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: context.colors.primaryGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: _mascota.imagenPrincipal != null
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              child: Image.network(
                _mascota.imagenPrincipal!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder(context);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            )
          : _buildImagePlaceholder(context),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 8),
          Text(
            _mascota.nombre ?? 'Mascota',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    // 👈 Usar el nuevo helper para obtener el color
    final color = context.colors.lost;
    final label = _mascota.estadoLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfo(
    BuildContext context,
    UsuarioBasicoModel duenoInfo,
    MascotaUsuarioModel dueno,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          ProfileAvatar(
            imageUrl: duenoInfo
                .fotoPerfil, // Aquí iría la foto del dueño si la tienes
            radius: 25,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dueño',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
                Text(
                  duenoInfo.nombre,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
                if (dueno.esPrincipal)
                  Text(
                    'Principal',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.verified_user, color: context.colors.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Grid de detalles
          _buildDetailRow(
            context,
            icon: Icons.pets,
            label: 'Tipo',
            value: _mascota.tipo,
          ),
          _buildDetailRow(
            context,
            icon: Icons.favorite,
            label: 'Sexo',
            value: _isEditing
                ? _buildSexoDropdown(context)
                : _mascota.sexo ?? 'No especificado',
          ),
          _buildDetailRow(
            context,
            icon: Icons.category,
            label: 'Raza',
            value: _isEditing
                ? TextFormField(
                    controller: _razaController,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Raza',
                      hintStyle: TextStyle(color: context.colors.textTertiary),
                    ),
                  )
                : _mascota.raza ?? 'No especificada',
          ),
          _buildDetailRow(
            context,
            icon: Icons.palette,
            label: 'Color',
            value: _isEditing
                ? TextFormField(
                    controller: _colorController,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Color',
                      hintStyle: TextStyle(color: context.colors.textTertiary),
                    ),
                  )
                : _mascota.color ?? 'No especificado',
          ),
          _buildDetailRow(
            context,
            icon: Icons.access_time,
            label: 'Edad',
            value: _isEditing
                ? Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _edadController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: context.colors.textPrimary),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Edad',
                            hintStyle: TextStyle(
                              color: context.colors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _buildEdadTiempoDropdown(context)),
                    ],
                  )
                : _mascota.edad != null
                ? '${_mascota.edad} ${_mascota.edadTiempo ?? 'años'}'
                : 'No especificada',
          ),
          _buildDetailRow(
            context,
            icon: Icons.straighten,
            label: 'Tamaño',
            value: _isEditing
                ? _buildTamanoDropdown(context)
                : _mascota.tamano ?? 'No especificado',
          ),
          _buildDetailRow(
            context,
            icon: Icons.monitor_weight,
            label: 'Peso',
            value: _isEditing
                ? TextFormField(
                    controller: _pesoController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Peso (kg)',
                      hintStyle: TextStyle(color: context.colors.textTertiary),
                    ),
                  )
                : _mascota.peso != null
                ? '${_mascota.peso} kg'
                : 'No especificado',
          ),
          _buildDetailRow(
            context,
            icon: Icons.medical_services,
            label: 'Esterilizado',
            value: _isEditing
                ? Switch(
                    value: _esterilizado,
                    onChanged: (value) => setState(() => _esterilizado = value),
                    activeColor: context.colors.primary,
                  )
                : _mascota.esterilizado
                ? 'Sí'
                : 'No',
          ),
          _buildDetailRow(
            context,
            icon: Icons.vaccines,
            label: 'Vacunado',
            value: _isEditing
                ? Switch(
                    value: _vacunado,
                    onChanged: (value) => setState(() => _vacunado = value),
                    activeColor: context.colors.primary,
                  )
                : _mascota.vacunado
                ? 'Sí'
                : 'No',
          ),
          _buildDetailRow(
            context,
            icon: Icons.qr_code,
            label: 'Microchip',
            value: _isEditing
                ? TextFormField(
                    controller: _microchipController,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Microchip',
                      hintStyle: TextStyle(color: context.colors.textTertiary),
                    ),
                  )
                : _mascota.microchip ?? 'No registrado',
          ),

          if (_isEditing) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _guardarCambios,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Guardar cambios',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required dynamic value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: context.colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: value is Widget
                ? value
                : Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexoDropdown(BuildContext context) {
    const options = ['Macho', 'Hembra'];

    // 👈 Asegurar que el valor seleccionado existe en las opciones
    final currentValue =
        _selectedSexo != null && options.contains(_selectedSexo)
        ? _selectedSexo
        : null;
    return DropdownButton<String>(
      value: currentValue,
      hint: Text(
        'Seleccionar',
        style: TextStyle(color: context.colors.textTertiary),
      ),
      underline: const SizedBox(),
      icon: Icon(Icons.arrow_drop_down, color: context.colors.textSecondary),
      isExpanded: true,
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: TextStyle(color: context.colors.textPrimary),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedSexo = value),
    );
  }

  // Corregir _buildTamanoDropdown
  Widget _buildTamanoDropdown(BuildContext context) {
    const options = ['Pequeño', 'Mediano', 'Grande'];

    final currentValue =
        _selectedTamano != null && options.contains(_selectedTamano)
        ? _selectedTamano
        : null;

    return DropdownButton<String>(
      value: currentValue,
      hint: Text(
        'Seleccionar',
        style: TextStyle(color: context.colors.textTertiary),
      ),
      underline: const SizedBox(),
      icon: Icon(Icons.arrow_drop_down, color: context.colors.textSecondary),
      isExpanded: true,
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: TextStyle(color: context.colors.textPrimary),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedTamano = value),
    );
  }

  // Corregir _buildEdadTiempoDropdown
  Widget _buildEdadTiempoDropdown(BuildContext context) {
    const options = ['meses', 'años'];

    final currentValue =
        _selectedEdadTiempo != null && options.contains(_selectedEdadTiempo)
        ? _selectedEdadTiempo
        : null;

    return DropdownButton<String>(
      value: currentValue,
      hint: Text(
        'Tiempo',
        style: TextStyle(color: context.colors.textTertiary),
      ),
      underline: const SizedBox(),
      icon: Icon(Icons.arrow_drop_down, color: context.colors.textSecondary),
      isExpanded: true,
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: TextStyle(color: context.colors.textPrimary),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedEdadTiempo = value),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // 👈 Si la mascota está activa, mostrar "Reportar pérdida"
    if (_mascota.isActivo) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _reportarPerdida(context),
              icon: const Icon(Icons.pets),
              label: const Text('Reportar pérdida'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.lost,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 👈 Si la mascota está perdida, mostrar "Reportar encontrada"
    if (_mascota.isPerdido) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _reportarEncontrada(context),
              icon: const Icon(Icons.favorite),
              label: const Text('Reportar encontrada'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.found,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 👈 Si la mascota está encontrada, adoptada o fallecida
    if (_mascota.isEncontrado || _mascota.isAdoptado || _mascota.isFallecido) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _mascota.isEncontrado
                  ? Icons.check_circle
                  : _mascota.isAdoptado
                  ? Icons.home
                  : Icons.info,
              color: _mascota.isEncontrado
                  ? context.colors.found
                  : _mascota.isAdoptado
                  ? context.colors.adoption
                  : context.colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              _mascota.isEncontrado
                  ? 'Mascota ya fue encontrada'
                  : _mascota.isAdoptado
                  ? 'Mascota adoptada'
                  : 'Estado: ${_mascota.estadoLabel}',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Fallback (por si acaso)
    return const SizedBox.shrink();
  }

  // =========================
  // MÉTODOS PARA REPORTAR
  // =========================

  void _reportarPerdida(BuildContext context) {
    // Aquí irá la navegación al formulario de reporte de pérdida
    Get.to(() => ReportarPerdidaPage(mascota: _mascota));
  }

  void _reportarEncontrada(BuildContext context) {
    // Aquí irá la navegación al formulario de reporte de encontrada
    Get.snackbar(
      'Info',
      'Funcionalidad en desarrollo - Reportar encontrada',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: context.colors.info,
      colorText: Colors.white,
    );
  }

  void _guardarCambios() async {
    try {
      final data = {
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text.isNotEmpty
            ? _descripcionController.text
            : null,
        'raza': _razaController.text.isNotEmpty ? _razaController.text : null,
        'color': _colorController.text.isNotEmpty
            ? _colorController.text
            : null,
        'edad': _edadController.text.isNotEmpty
            ? int.tryParse(_edadController.text)
            : null,
        'edad_tiempo': _selectedEdadTiempo,
        'sexo': _selectedSexo,
        'tamano': _selectedTamano,
        'peso': _pesoController.text.isNotEmpty
            ? double.tryParse(_pesoController.text)
            : null,
        'esterilizado': _esterilizado,
        'vacunado': _vacunado,
        'microchip': _microchipController.text.isNotEmpty
            ? _microchipController.text
            : null,
      };

      await _controller.updateMascota(mascotaId: _mascota.id, data: data);

      setState(() {
        _isEditing = false;
        // Actualizar la mascota local
        _mascota = _mascota.copyWith(
          nombre: _nombreController.text,
          descripcion: _descripcionController.text.isNotEmpty
              ? _descripcionController.text
              : null,
          raza: _razaController.text.isNotEmpty ? _razaController.text : null,
          color: _colorController.text.isNotEmpty
              ? _colorController.text
              : null,
          edad: _edadController.text.isNotEmpty
              ? int.tryParse(_edadController.text)
              : null,
          edadTiempo: _selectedEdadTiempo,
          sexo: _selectedSexo,
          tamano: _selectedTamano,
          peso: _pesoController.text.isNotEmpty
              ? double.tryParse(_pesoController.text)
              : null,
          esterilizado: _esterilizado,
          vacunado: _vacunado,
          microchip: _microchipController.text.isNotEmpty
              ? _microchipController.text
              : null,
        );
      });

      Get.snackbar(
        'Éxito',
        'Mascota actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.colors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la mascota',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.colors.error,
        colorText: Colors.white,
      );
    }
  }
}
