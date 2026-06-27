import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  MapController? mapController;
  final List<Marker> _markers = [];
  bool _showBottomSheet = false;
  LatLng? _currentLocation;
  bool _isLoading = true;
  String _selectedMarkerId = '';

  // Datos de ejemplo para mascotas
  List<Map<String, dynamic>> get _petsData => [
    {
      'id': '1',
      'name': 'Luna',
      'type': 'Perdida',
      'breed': 'Gato Siberiano',
      'location': 'Sopocachi, La Paz',
      'coordinates': LatLng(-16.5000, -68.1500),
      'time': 'Hace 2 horas',
      'image': 'https://images.dog.ceo/breeds/cat/siberian.jpg',
      'color': context.colors.lost, // 👈 Usa el context actual
      'description': 'Se perdió cerca de la plaza, tiene collar rojo',
      'user': 'María González',
      'contact': '+591 71234567',
    },
    {
      'id': '2',
      'name': 'Max',
      'type': 'Adopción',
      'breed': 'Golden Retriever',
      'location': 'Calacoto, La Paz',
      'coordinates': LatLng(-16.5100, -68.1400),
      'time': 'Hace 1 día',
      'image': 'https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg',
      'color': context.colors.adoption,
      'description': 'Muy juguetón y amoroso, busca hogar',
      'user': 'Carlos Mendoza',
      'contact': '+591 72345678',
    },
    {
      'id': '3',
      'name': 'Bella',
      'type': 'Encontrada',
      'breed': 'Pastor Alemán',
      'location': 'Miraflores, La Paz',
      'coordinates': LatLng(-16.4950, -68.1350),
      'time': 'Hace 5 horas',
      'image':
          'https://images.dog.ceo/breeds/shepherd-german/n02106662_100.jpg',
      'color': context.colors.found,
      'description': 'Encontrada en el parque central',
      'user': 'Ana Lucía',
      'contact': '+591 73456789',
    },
    {
      'id': '4',
      'name': 'Rocky',
      'type': 'Rescatado',
      'breed': 'Criollo',
      'location': 'Obrajes, La Paz',
      'coordinates': LatLng(-16.5200, -68.1200),
      'time': 'Hace 3 días',
      'image': 'https://images.dog.ceo/breeds/mix/n02113712_100.jpg',
      'color': context.colors.rescued,
      'description': 'Rescatado de la calle, necesita hogar temporal',
      'user': 'Refugio Patitas',
      'contact': '+591 74567890',
    },
  ];

  // Filtros
  Set<String> _selectedFilters = {
    'Perdida',
    'Adopción',
    'Encontrada',
    'Rescatado',
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMarkers();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMarkers() {
    _markers.clear();

    for (var pet in _petsData) {
      if (_selectedFilters.contains(pet['type'])) {
        _markers.add(
          Marker(
            point: pet['coordinates'],
            width: 60,
            height: 60,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMarkerId = pet['id'];
                  _showBottomSheet = true;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: pet['color'] as Color,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipOval(
                          child: Image.network(
                            pet['image'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.pets,
                                size: 24,
                                color: pet['color'],
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Icon(
                              _getTypeIcon(pet['type']),
                              size: 12,
                              color: pet['color'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Perdida':
        return Icons.pets;
      case 'Adopción':
        return Icons.home;
      case 'Encontrada':
        return Icons.favorite;
      case 'Rescatado':
        return Icons.medical_services;
      default:
        return Icons.location_on;
    }
  }

  void _centerToLocation() {
    if (_currentLocation != null && mapController != null) {
      mapController!.move(_currentLocation!, 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mascotas Cerca',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        foregroundColor: context.colors.textPrimary,
        backgroundColor: context.colors.cardBackground,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: context.colors.textPrimary),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.my_location, color: context.colors.textPrimary),
            onPressed: _centerToLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
           Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            ),

          if (!_isLoading)
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter:
                    _currentLocation ?? const LatLng(-16.5000, -68.1500),
                initialZoom: 13,
                onTap: (_, __) {
                  setState(() {
                    _showBottomSheet = false;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.patitas.unidas',
                ),
                MarkerLayer(markers: _markers),
                // Marcador de ubicación actual
                if (_currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLocation!,
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colors.primary,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

          // Bottom Sheet para detalles
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showBottomSheet ? null : 0,
              child: _showBottomSheet
                  ? _buildPetDetailsCard()
                  : const SizedBox.shrink(),
            ),
          ),

          // Botón de ayuda flotante
          Positioned(
            bottom: _showBottomSheet ? 180 : 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _centerToLocation,
              backgroundColor: context.colors.primary,
              mini: true,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetDetailsCard() {
    final pet = _petsData.firstWhere(
      (p) => p['id'] == _selectedMarkerId,
      orElse: () => _petsData[0],
    );

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagen y header
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(pet['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: pet['color'],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getTypeIcon(pet['type']),
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  pet['type'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pet['time'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pet['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Raza
                  Row(
                    children: [
                     Icon(
                        Icons.pets,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pet['breed'],
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Ubicación
                  Row(
                    children: [
                     Icon(
                        Icons.location_on,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pet['location'],
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Descripción
                  Text(
                    pet['description'],
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),

                  const SizedBox(height: 16),

                  // Usuario y contacto
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                       CircleAvatar(
                          radius: 20,
                          backgroundColor: context.colors.primary,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet['user'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                pet['contact'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showContactDialog(pet);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Contactar'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _sharePet(pet);
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Compartir'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.primary,
                            side: BorderSide(color: context.colors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showHelpOptions(pet);
                          },
                          icon: const Icon(Icons.volunteer_activism),
                          label: Text(
                            pet['type'] == 'Perdida' ? 'Ayudar' : 'Más info',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar mascotas',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                 Text(
                    'Selecciona los tipos de mascotas que quieres ver',
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // Filtros
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildFilterChip(
                        'Perdida',
                        context.colors.lost,
                        setStateModal,
                      ),
                      _buildFilterChip(
                        'Adopción',
                        context.colors.adoption,
                        setStateModal,
                      ),
                      _buildFilterChip(
                        'Encontrada',
                        context.colors.found,
                        setStateModal,
                      ),
                      _buildFilterChip(
                        'Rescatado',
                        context.colors.rescued,
                        setStateModal,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Rango de distancia (opcional)
                  const Text(
                    'Radio de búsqueda',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: 5,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: '5 km',
                    onChanged: (value) {},
                    activeColor: context.colors.primary,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilters = {
                                'Perdida',
                                'Adopción',
                                'Encontrada',
                                'Rescatado',
                              };
                            });
                            _loadMarkers();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.textSecondary,
                            side: BorderSide(color: context.colors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Reiniciar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _loadMarkers();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Aplicar Filtros'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    Color color,
    StateSetter setStateModal,
  ) {
    final isSelected = _selectedFilters.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setStateModal(() {
          if (selected) {
            _selectedFilters.add(label);
          } else {
            _selectedFilters.remove(label);
          }
        });
      },
      backgroundColor: Colors.white,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : context.colors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : context.colors.border,
        width: 1.5,
      ),
    );
  }

  void _showContactDialog(Map<String, dynamic> pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Contactar sobre ${pet['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           Icon(Icons.phone, size: 48, color: context.colors.primary),
            const SizedBox(height: 16),
            Text(
              pet['contact'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Llamar o enviar WhatsApp para más información'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Contactando a ${pet['user']}...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
            child: const Text('Contactar'),
          ),
        ],
      ),
    );
  }

  void _sharePet(Map<String, dynamic> pet) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo información de ${pet['name']}...'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _showHelpOptions(Map<String, dynamic> pet) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Cómo puedes ayudar?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.share, color: context.colors.primary),
              ),
              title: const Text('Compartir publicación'),
              subtitle: const Text('Ayuda a llegar a más personas'),
              onTap: () {
                Navigator.pop(context);
                _sharePet(pet);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.message, color: context.colors.primary),
              ),
              title: const Text('Contactar al usuario'),
              subtitle: const Text('Ofrece información o ayuda directa'),
              onTap: () {
                Navigator.pop(context);
                _showContactDialog(pet);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.volunteer_activism,
                  color: context.colors.primary,
                ),
              ),
              title: const Text('Ofrecer ayuda temporal'),
              subtitle: const Text(
                'Puedes ofrecer hogar temporal o donaciones',
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gracias por tu interés en ayudar'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
