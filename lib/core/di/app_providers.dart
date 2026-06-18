import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/local_storage_service.dart';

/// Provider del servicio de almacenamiento local
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// Provider del tema (reactivo, persistido)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(localStorageProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorageService _storage;

  ThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await _storage.getThemeMode();
    state = _fromString(mode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _storage.setThemeMode(_toString(mode));
  }

  ThemeMode _fromString(String s) {
    switch (s) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  String _toString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      case ThemeMode.system: return 'system';
    }
  }
}

/// Provider de cámaras favoritas (reactivo, persistido)
final favoriteCamerasProvider = StateNotifierProvider<FavoriteCamerasNotifier, List<String>>((ref) {
  return FavoriteCamerasNotifier(ref.watch(localStorageProvider));
});

class FavoriteCamerasNotifier extends StateNotifier<List<String>> {
  final LocalStorageService _storage;

  FavoriteCamerasNotifier(this._storage) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _storage.getFavoriteCameras();
  }

  Future<void> toggle(String cameraId) async {
    await _storage.toggleFavoriteCamera(cameraId);
    state = await _storage.getFavoriteCameras();
  }

  bool isFavorite(String cameraId) => state.contains(cameraId);
}

/// Provider de calidad de streaming
final streamQualityProvider = StateProvider<String>((ref) => 'auto');

/// Provider Wi-Fi only
final wifiOnlyProvider = StateProvider<bool>((ref) => false);

/// Provider notificaciones habilitadas
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

/// Provider texto grande (accesibilidad)
final largeTextProvider = StateProvider<bool>((ref) => false);

/// Provider alto contraste (accesibilidad)
final highContrastProvider = StateProvider<bool>((ref) => false);

/// Provider de la URL base del backend de IA (persiste en SharedPreferences)
final iaBaseUrlProvider = StateNotifierProvider<IaBaseUrlNotifier, String>((ref) {
  return IaBaseUrlNotifier(ref.watch(localStorageProvider));
});

class IaBaseUrlNotifier extends StateNotifier<String> {
  final LocalStorageService _storage;

  IaBaseUrlNotifier(this._storage) : super('') {
    _load();
  }

  Future<void> _load() async {
    state = await _storage.getBackendBaseUrl();
  }

  Future<void> setUrl(String url) async {
    state = url;
    await _storage.setBackendBaseUrl(url);
  }
}

/// Provider del ID de la cámara de IA (persiste en SharedPreferences)
final iaCameraIdProvider = StateNotifierProvider<IaCameraIdNotifier, String>((ref) {
  return IaCameraIdNotifier(ref.watch(localStorageProvider));
});

class IaCameraIdNotifier extends StateNotifier<String> {
  final LocalStorageService _storage;

  IaCameraIdNotifier(this._storage) : super('cam-phone') {
    _load();
  }

  Future<void> _load() async {
    state = await _storage.getBackendCameraId();
  }

  Future<void> setCameraId(String cameraId) async {
    state = cameraId;
    await _storage.setBackendCameraId(cameraId);
  }
}

/// Provider de Dio dedicado para comunicación con el servidor IA local
final iaDioProvider = Provider<Dio?>((ref) {
  final baseUrl = ref.watch(iaBaseUrlProvider);
  if (baseUrl.isEmpty) return null;
  return Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});
