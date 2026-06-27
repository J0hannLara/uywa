// lib/features/perdidas/presentation/pages/reportar_perdida_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:mypets/core/theme/app_colors.dart';
import '../../../mascotas/data/models/mascotas_model.dart';
import '../controllers/perdidas_controller.dart';

class ReportarPerdidaPage extends StatefulWidget {
  final MascotaModel mascota;

  const ReportarPerdidaPage({super.key, required this.mascota});

  @override
  State<ReportarPerdidaPage> createState() => _ReportarPerdidaPageState();
}

class _ReportarPerdidaPageState extends State<ReportarPerdidaPage> {
  final PerdidaController _controller = Get.find<PerdidaController>();
  
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
  final _lugarController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _recompensaController = TextEditingController();
  final _radioController = TextEditingController(text: '5');
  
  // Fecha y hora
  DateTime _fechaPerdida = DateTime.now();
  TimeOfDay _horaPerdida = TimeOfDay.now();
  
  // Ubicación
  LatLng? _ubicacionActual;
  bool _obteniendoUbicacion = false;
  
  // Recompensa
  bool _ofreceRecompensa = false;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionActual();
  }

  @override
  void dispose() {
    _lugarController.dispose();
    _descripcionController.dispose();
    _recompensaController.dispose();
    _radioController.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacionActual() async {
    setState(() => _obteniendoUbicacion = true);
    
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permiso denegado',
            'No se pudo obtener tu ubicación. Por favor ingresa la ubicación manualmente.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: context.colors.warning,
            colorText: Colors.white,
          );
          setState(() => _obteniendoUbicacion = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permiso denegado permanentemente',
          'Activa la ubicación desde los ajustes del dispositivo.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: context.colors.error,
          colorText: Colors.white,
        );
        setState(() => _obteniendoUbicacion = false);
        return;
      }

      // Obtener ubicación
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _ubicacionActual = LatLng(position.latitude, position.longitude);
        _obteniendoUbicacion = false;
      });

      // Obtener dirección desde coordenadas
      final placemarks = await _obtenerDireccionDesdeCoordenadas(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks != null && _lugarController.text.isEmpty) {
        _lugarController.text = placemarks;
      }

    } catch (e) {
      print('Error obteniendo ubicación: $e');
      setState(() => _obteniendoUbicacion = false);
      Get.snackbar(
        'Error',
        'No se pudo obtener tu ubicación. Ingresa la ubicación manualmente.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.colors.warning,
        colorText: Colors.white,
      );
    }
  }

  Future<String?> _obtenerDireccionDesdeCoordenadas(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.isNotEmpty);
        return parts.join(', ');
      }
    } catch (e) {
      print('Error obteniendo dirección: $e');
    }
    return null;
  }

  Future<void> _seleccionarFecha() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaPerdida,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _fechaPerdida = date);
    }
  }

  Future<void> _seleccionarHora() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _horaPerdida,
    );
    if (time != null) {
      setState(() => _horaPerdida = time);
    }
  }

  void _confirmarRegistro() {
    if (!_formKey.currentState!.validate()) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: context.colors.surface,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: context.colors.lost),
            const SizedBox(width: 12),
            Text(
              '¿Confirmar pérdida?',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estás a punto de reportar a',
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.mascota.nombre ?? 'Tu mascota'}',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.lost.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.lost.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: context.colors.lost),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acción cambiará el estado de tu mascota a "Perdido" y será visible para todos los usuarios.',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => _guardarPerdida(),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.lost,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar pérdida'),
          ),
        ],
      ),
    );
  }

  void _guardarPerdida() async {
    Get.back(); // Cerrar diálogo de confirmación

    final fechaCompleta = DateTime(
      _fechaPerdida.year,
      _fechaPerdida.month,
      _fechaPerdida.day,
      _horaPerdida.hour,
      _horaPerdida.minute,
    );

    await _controller.createPerdida(
      idMascota: widget.mascota.id,
      fechaPerdida: fechaCompleta,
      lugarPerdida: _lugarController.text,
      descripcionPerdida: _descripcionController.text.isNotEmpty 
          ? _descripcionController.text 
          : null,
      latitud: _ubicacionActual?.latitude,
      longitud: _ubicacionActual?.longitude,
      radioBusquedaKm: int.tryParse(_radioController.text) ?? 5,
      recompensa: _ofreceRecompensa && _recompensaController.text.isNotEmpty
          ? double.tryParse(_recompensaController.text)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reportar pérdida',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
                fontSize: 18,
              ),
            ),
            Text(
              'Registrar a ${widget.mascota.nombre ?? 'tu mascota'} como perdida',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Obx(() => TextButton(
            onPressed: _controller.isSubmitting.value ? null : _confirmarRegistro,
            child: _controller.isSubmitting.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.primary,
                    ),
                  )
                : Text(
                    'Guardar',
                    style: TextStyle(
                      color: context.colors.lost,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          )),
        ],
      ),
      body: Obx(() {
        if (_controller.isSubmitting.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Guardando reporte...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información de la mascota
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: widget.mascota.imagenPrincipal != null
                            ? NetworkImage(widget.mascota.imagenPrincipal!)
                            : null,
                        backgroundColor: context.colors.primary.withOpacity(0.2),
                        child: widget.mascota.imagenPrincipal == null
                            ? Icon(Icons.pets, color: context.colors.primary)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.mascota.nombre ?? 'Sin nombre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            Text(
                              widget.mascota.tipo,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colors.lost.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Perdido',
                          style: TextStyle(
                            color: context.colors.lost,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Fecha y hora
                Text(
                  'Fecha y hora de la pérdida',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimePicker(context),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Lugar de pérdida
                _buildTextField(
                  controller: _lugarController,
                  label: 'Lugar de pérdida',
                  hint: 'Ej: Parque Las Américas, Zona Sur',
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el lugar de la pérdida';
                    }
                    return null;
                  },
                  suffixIcon: _obteniendoUbicacion
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.my_location,
                            color: context.colors.primary,
                          ),
                          onPressed: _obtenerUbicacionActual,
                          tooltip: 'Usar mi ubicación',
                        ),
                ),

                const SizedBox(height: 16),

                // Descripción
                _buildTextField(
                  controller: _descripcionController,
                  label: 'Descripción adicional',
                  hint: 'Detalles sobre cómo y dónde se perdió...',
                  icon: Icons.description,
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // Radio de búsqueda
                _buildTextField(
                  controller: _radioController,
                  label: 'Radio de búsqueda (km)',
                  hint: '5',
                  icon: Icons.radio_button_checked,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                // Recompensa
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          'Ofrecer recompensa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Ofrece una recompensa para incentivar la búsqueda',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        value: _ofreceRecompensa,
                        onChanged: (value) {
                          setState(() {
                            _ofreceRecompensa = value;
                            if (!value) {
                              _recompensaController.clear();
                            }
                          });
                        },
                        activeColor: context.colors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_ofreceRecompensa) ...[
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _recompensaController,
                          label: 'Monto de la recompensa',
                          hint: 'Ej: 500.00',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          prefixText: 'Bs ',
                          validator: (value) {
                            if (_ofreceRecompensa && (value == null || value.isEmpty)) {
                              return 'Ingresa el monto de la recompensa';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: TextStyle(
            fontSize: 12,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: _seleccionarFecha,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: context.colors.primary),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd/MM/yyyy').format(_fechaPerdida),
                  style: TextStyle(color: context.colors.textPrimary, fontSize: 15),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: context.colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hora',
          style: TextStyle(
            fontSize: 12,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: _seleccionarHora,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 20, color: context.colors.primary),
                const SizedBox(width: 12),
                Text(
                  _horaPerdida.format(context),
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: context.colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? prefixText,
    String? Function(String?)? validator,
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
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: context.colors.textPrimary),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.colors.textTertiary),
            prefixIcon: Icon(icon, color: context.colors.primary),
            prefixText: prefixText,
            prefixStyle: TextStyle(color: context.colors.textPrimary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: context.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.primary, width: 2),
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
}