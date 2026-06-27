// lib/features/perdidas/presentation/widgets/perdida_map_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/perdidas_model.dart';

class PerdidaMapWidget extends StatefulWidget {
  final PerdidaModel perdida;
  final double? radiusKm;

  const PerdidaMapWidget({super.key, required this.perdida, this.radiusKm});

  @override
  State<PerdidaMapWidget> createState() => _PerdidaMapWidgetState();
}

class _PerdidaMapWidgetState extends State<PerdidaMapWidget> {
  late MapController _mapController;
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _hasLocationPermission = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _hasLocationPermission = false;
        });
        return;
      }

      // Obtener ubicación
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
        _hasLocationPermission = true;
      });

      // Centrar el mapa en la ubicación de la pérdida
      _mapController.move(
        LatLng(widget.perdida.latitud!, widget.perdida.longitud!),
        13,
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      setState(() {
        _isLoadingLocation = false;
        _hasLocationPermission = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final perdidaLocation = LatLng(
      widget.perdida.latitud!,
      widget.perdida.longitud!,
    );

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: perdidaLocation,
            initialZoom: 13,
            onTap: (tapPosition, point) {
              // Opcional: permitir interactuar con el mapa
            },
          ),
          children: [
            // Capa de tiles de OpenStreetMap
            TileLayer(
              urlTemplate:
                  'https://stamen-tiles-{s}.a.ssl.fastly.net/terrain/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.app',
            ),

            // Capa de marcadores
            MarkerLayer(
              markers: [
                // Marcador de la pérdida
                Marker(
                  point: perdidaLocation,
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colors.lost,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      Container(
                        width: 0,
                        height: 0,
                        decoration: BoxDecoration(
                          color: context.colors.lost,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),

                // Marcador de ubicación actual (si está disponible)
                if (_currentLocation != null)
                  Marker(
                    point: _currentLocation!,
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        Container(
                          width: 0,
                          height: 0,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Capa de círculo (radio de búsqueda)
            CircleLayer(
              circles: [
                CircleMarker(
                  point: perdidaLocation,
                  radius:
                      (widget.radiusKm ?? widget.perdida.radioBusquedaKm) *
                      1000,
                  color: context.colors.lost.withOpacity(0.15),
                  borderColor: context.colors.lost.withOpacity(0.5),
                  borderStrokeWidth: 2,
                ),
              ],
            ),

            // Capa de info (texto de coordenadas)
            if (_isLoadingLocation)
              const Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
