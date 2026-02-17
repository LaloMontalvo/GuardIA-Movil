# GuardIA - App Móvil de Videovigilancia con IA

Plataforma móvil de videovigilancia comunitaria con alertas inteligentes, evidencia visual y mapa interactivo.

## 📱 Características MVP

- ✅ Autenticación con JWT (login/registro)
- ✅ Dashboard con estadísticas de cámaras y alertas
- ✅ Lista de cámaras con búsqueda y filtros
- ✅ Vista en vivo placeholder (preparada para HLS/RTSP)
- ✅ Centro de alertas con filtros por estado
- ✅ Detalle de alertas con evidencia e imagen
- ✅ Gestión de estado de alertas (confirmar/falso positivo/resolver)
- ✅ Ajustes (tema claro/oscuro, WiFi, notificaciones)
- ✅ Botón de pánico
- ✅ Arquitectura Clean Architecture
- ✅ Estado con Riverpod
- ✅ Navegación con go_router + guards
- ✅ MockAPI para desarrollo sin backend

## 🏗️ Arquitectura

```
lib/
├── app/                    # Configuración de la app
│   ├── app.dart
│   ├── app_router.dart
│   └── theme/
├── core/                   # Núcleo compartido
│   ├── constants/
│   ├── di/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   └── utils/
├── features/               # Features (Clean Architecture)
│   ├── auth/
│   ├── cameras/
│   ├── alerts/
│   ├── dashboard/
│   └── settings/
├── shared/                 # Widgets compartidos
└── main.dart
```

Cada feature sigue la estructura:
```
feature/
├── data/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── enums/
│   └── repositories/
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

## 🚀 Cómo ejecutar

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. (Opcional) Generar código con build_runner

Si los modelos usan freezed/json_serializable:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Ejecutar la app

```bash
# En dispositivo/emulador
flutter run

# En modo release
flutter run --release
```

## 🔑 Credenciales de prueba

**Administrador:**
- Email: `admin@guardia.com`
- Password: `admin123`

**Usuario:**
- Email: `user@guardia.com`
- Password: `user123`

## 📦 Dependencias principales

- `flutter_riverpod ^2.4.0` - Gestión de estado
- `go_router ^13.0.0` - Navegación declarativa
- `dio ^5.4.0` - Cliente HTTP
- `flutter_secure_storage ^9.0.0` - Almacenamiento seguro
- `cached_network_image ^3.3.0` - Caché de imágenes
- `intl ^0.19.0` - Internacionalización

Ver `pubspec.yaml` para la lista completa.

## 🎯 Decisiones técnicas

### ¿Por qué Riverpod?
- Type-safe y compile-time safe
- Mejor testabilidad que Provider
- Sin necesidad de BuildContext
- Soporte para async/await nativo

### ¿Por qué go_router?
- Navegación declarativa moderna
- Guards integrados (auth, roles)
- Deep linking preparado
- Shell routes para layouts comunes

### ¿Por qué Dio?
- Interceptors potentes (auth, refresh, logs)
- Manejo de errores robusto
- Timeouts configurables
- Cancelación de requests

### ¿Por qué MockAPI?
- Desarrollo sin dependencia de backend
- Testing más fácil
- Datos simulados realistas con delays
- Fácil cambio a API real (flag `useMockApi`)

## 🗺️ Roadmap

### MVP (v1.0) ✅
- [x] Autenticación básica
- [x] Dashboard
- [x] Lista de cámaras
- [x] Lista de alertas
- [x] Detalle de alertas
- [x] Ajustes básicos

### v1.1 (Post-MVP)
- [ ] Integración streaming HLS/RTSP
- [ ] Notificaciones push FCM
- [ ] Módulo de grabaciones
- [ ] Filtros avanzados de alertas
- [ ] Búsqueda global

### v1.2
- [ ] Mapa interactivo con cámaras
- [ ] Casos/evidencias
- [ ] Exportar reportes
- [ ] Modo offline con sincronización

### v2.0
- [ ] Panel de administración
- [ ] Gestión de usuarios y roles
- [ ] Configuración de reglas de alertas
- [ ] Retención de grabaciones
- [ ] Analytics y dashboard avanzado

## 🔧 Configuración

### Cambiar a API real

En `lib/core/constants/app_constants.dart`:

```dart
static const bool useMockApi = false; // Cambiar a false
```

Luego actualizar `lib/core/constants/api_constants.dart` con la URL real.

### Cambiar tema por defecto

En `lib/features/settings/presentation/screens/settings_screen.dart`:

```dart
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
```

## 📄 Licencia

Proyecto demo para GuardIA MVP.
