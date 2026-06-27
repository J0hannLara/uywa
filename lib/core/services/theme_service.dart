import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  final RxBool _isDarkMode = true.obs;
  
  bool get isDarkMode => _isDarkMode.value;
  
  // Opciones: 'light', 'dark', 'system'
  final RxString _themeMode = 'system'.obs;
  String get themeMode => _themeMode.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
    _listenToSystemTheme();
  }
  
  // Cambiar modo de tema
  Future<void> setThemeMode(String mode) async {
    _themeMode.value = mode;
    _applyTheme();
    await _saveThemePreference(mode);
  }
  
  // Aplicar tema según la selección
  void _applyTheme() {
    bool isDark;
    
    switch (_themeMode.value) {
      case 'light':
        isDark = false;
        break;
      case 'dark':
        isDark = true;
        break;
      case 'system':
      default:
        isDark = _isSystemDarkMode();
        break;
    }
    
    _isDarkMode.value = isDark;
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
  
  bool _isSystemDarkMode() {
    return WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
  }
  
  void _listenToSystemTheme() {
    // Escuchar cambios en el tema del sistema
    WidgetsBinding.instance.window.onPlatformBrightnessChanged = () {
      if (_themeMode.value == 'system') {
        _applyTheme();
      }
    };
  }
  
  // Guardar preferencia
  Future<void> _saveThemePreference(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
  }
  
  // Cargar preferencia
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('theme_mode') ?? 'system';
    _themeMode.value = savedMode;
    _applyTheme();
  }
  
  // Métodos de conveniencia
  void toggleDarkMode() {
    final newMode = _isDarkMode.value ? 'light' : 'dark';
    setThemeMode(newMode);
  }
  
  void setDarkMode(bool enabled) {
    setThemeMode(enabled ? 'dark' : 'light');
  }
  
  void setSystemMode() {
    setThemeMode('system');
  }
}