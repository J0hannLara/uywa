import 'package:flutter/material.dart';
import 'package:mypets/core/services/primer_evento_service.dart';

import 'package:mypets/features/mapa/presentation/pages/map_page.dart';
import 'package:mypets/features/publicaciones/presentation/pages/create_post_page.dart';
import 'package:mypets/features/albergues/presentation/pages/albergues_page.dart';
import 'package:mypets/features/perfiles/presentation/pages/perfiles_page.dart';

import '../presentation/pages/home_page.dart';

import '../../../../core/theme/app_colors.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  bool _insigniaVerificada = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapsPage(),
    CreatePostPage(),
    AlberguesPage(),
    ProfilePage(),
  ];
  @override
  void initState() {
    super.initState();
    _verificarInsignia();
  }

  Future<void> _verificarInsignia() async {
    if (_insigniaVerificada) return;
    _insigniaVerificada = true;
    await PrimerEventoService.verificarYAsignarInsignia(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: context.colors.cardBackground,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: context.colors.primary, // Color cuando está seleccionado
        unselectedItemColor: context.colors.textSecondary, // Color cuando NO está seleccionado
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Publicar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Refugios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}