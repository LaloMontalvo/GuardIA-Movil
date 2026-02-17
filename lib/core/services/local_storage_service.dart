import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de almacenamiento local usando SharedPreferences
/// Maneja: favoritas, tema, onboarding, configuraciones del vecino
class LocalStorageService {
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyThemeMode = 'theme_mode';
  static const _keyLanguage = 'language';
  static const _keyFavoriteCameras = 'favorite_cameras';
  static const _keyWifiOnly = 'wifi_only';
  static const _keyStreamQuality = 'stream_quality';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyDndEnabled = 'dnd_enabled';
  static const _keyDndStart = 'dnd_start';
  static const _keyDndEnd = 'dnd_end';
  static const _keyBiometricEnabled = 'biometric_enabled';
  static const _keyPinEnabled = 'pin_enabled';
  static const _keyLargeText = 'large_text';
  static const _keyHighContrast = 'high_contrast';
  static const _keyRememberMe = 'remember_me';
  static const _keySelectedZone = 'selected_zone';
  static const _keyWelcomeSeen = 'welcome_seen';
  static const _keyPermissionsRequested = 'permissions_requested';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ========== ONBOARDING ==========
  Future<bool> hasSeenOnboarding() async => (await prefs).getBool(_keyOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool value) async => (await prefs).setBool(_keyOnboardingSeen, value);

  // ========== TEMA ==========
  Future<String> getThemeMode() async => (await prefs).getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) async => (await prefs).setString(_keyThemeMode, mode);

  // ========== IDIOMA ==========
  Future<String> getLanguage() async => (await prefs).getString(_keyLanguage) ?? 'es';
  Future<void> setLanguage(String lang) async => (await prefs).setString(_keyLanguage, lang);

  // ========== FAVORITAS ==========
  Future<List<String>> getFavoriteCameras() async => (await prefs).getStringList(_keyFavoriteCameras) ?? [];
  Future<void> setFavoriteCameras(List<String> ids) async => (await prefs).setStringList(_keyFavoriteCameras, ids);
  Future<void> toggleFavoriteCamera(String cameraId) async {
    final favorites = await getFavoriteCameras();
    if (favorites.contains(cameraId)) {
      favorites.remove(cameraId);
    } else {
      favorites.add(cameraId);
    }
    await setFavoriteCameras(favorites);
  }

  // ========== STREAMING ==========
  Future<bool> getWifiOnly() async => (await prefs).getBool(_keyWifiOnly) ?? false;
  Future<void> setWifiOnly(bool value) async => (await prefs).setBool(_keyWifiOnly, value);
  Future<String> getStreamQuality() async => (await prefs).getString(_keyStreamQuality) ?? 'auto';
  Future<void> setStreamQuality(String quality) async => (await prefs).setString(_keyStreamQuality, quality);

  // ========== NOTIFICACIONES ==========
  Future<bool> getNotificationsEnabled() async => (await prefs).getBool(_keyNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool value) async => (await prefs).setBool(_keyNotificationsEnabled, value);
  Future<bool> getDndEnabled() async => (await prefs).getBool(_keyDndEnabled) ?? false;
  Future<void> setDndEnabled(bool value) async => (await prefs).setBool(_keyDndEnabled, value);

  // ========== SEGURIDAD ==========
  Future<bool> getBiometricEnabled() async => (await prefs).getBool(_keyBiometricEnabled) ?? false;
  Future<void> setBiometricEnabled(bool value) async => (await prefs).setBool(_keyBiometricEnabled, value);
  Future<bool> getPinEnabled() async => (await prefs).getBool(_keyPinEnabled) ?? false;
  Future<void> setPinEnabled(bool value) async => (await prefs).setBool(_keyPinEnabled, value);

  // ========== ACCESIBILIDAD ==========
  Future<bool> getLargeText() async => (await prefs).getBool(_keyLargeText) ?? false;
  Future<void> setLargeText(bool value) async => (await prefs).setBool(_keyLargeText, value);
  Future<bool> getHighContrast() async => (await prefs).getBool(_keyHighContrast) ?? false;
  Future<void> setHighContrast(bool value) async => (await prefs).setBool(_keyHighContrast, value);

  // ========== REMEMBER ME ==========
  Future<bool> getRememberMe() async => (await prefs).getBool(_keyRememberMe) ?? false;
  Future<void> setRememberMe(bool value) async => (await prefs).setBool(_keyRememberMe, value);

  // ========== CACHE ==========
  Future<void> clearCache() async {
    // Solo borra configuraciones no críticas
    final p = await prefs;
    await p.remove(_keyFavoriteCameras);
  }

  Future<int> getCacheSize() async {
    // Estimación mock
    return 24 * 1024 * 1024; // 24 MB simulado
  }

  // ========== ZONA/COLONIA ==========
  Future<String?> getSelectedZone() async => (await prefs).getString(_keySelectedZone);
  Future<void> setSelectedZone(String zone) async => (await prefs).setString(_keySelectedZone, zone);

  // ========== BIENVENIDA ==========
  Future<bool> hasSeenWelcome() async => (await prefs).getBool(_keyWelcomeSeen) ?? false;
  Future<void> setWelcomeSeen(bool value) async => (await prefs).setBool(_keyWelcomeSeen, value);

  // ========== PERMISOS ==========
  Future<bool> hasRequestedPermissions() async => (await prefs).getBool(_keyPermissionsRequested) ?? false;
  Future<void> setPermissionsRequested(bool value) async => (await prefs).setBool(_keyPermissionsRequested, value);
}
