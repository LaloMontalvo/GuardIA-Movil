# Decisiones Técnicas - GuardIA MVP

## Arquitectura

### Clean Architecture
Hemos adoptado Clean Architecture para separar las responsabilidades y facilitar el testing y mantenibilidad:

- **Data Layer**: Maneja la comunicación con APIs, almacenamiento local y caché
- **Domain Layer**: Contiene las entidades puras y reglas de negocio
- **Presentation Layer**: UI con widgets y estado manejado por Riverpod

### Feature-first
La estructura de carpetas está organizada por features (auth, cameras, alerts, etc.) en lugar de por capas técnicas. Esto permite:
- Mejor escalabilidad
- Equipos pueden trabajar en features independientes
- Fácil identificación de código relacionado

## Estado

### Riverpod
Elegimos Riverpod sobre otras soluciones de estado por:

1. **Type safety**: Errores capturados en compile-time
2. **No BuildContext necesario**: Estados accesibles desde cualquier lugar
3. **Testing simplificado**: Providers fáciles de mockar
4. **AsyncValue**: Manejo elegante de estados loading/error/data
5. **Provider composition**: Fácil combinación de providers
6. **Performance**: Rebuilds optimizados

## Navegación

### go_router
Implementamos go_router para navegación declarativa:

1. **Guards integrados**: Auth redirect automático sin boilerplate
2. **Deep linking**: Preparado para URLs profundas
3. **Type-safe routes**: Parámetros de ruta validados
4. **ShellRoute**: Layouts persistentes (BottomNavigationBar)
5. **Declarative**: Estado de navegación como configuración

## Networking

### Dio
Usamos Dio como cliente HTTP por:

1. **Interceptors**: Chain de auth, refresh token y logging
2. **Cancelación**: Request cancellation built-in
3. **Error handling**: DioException con información detallada
4. **Timeouts configurables**: Connect y receive separados
5. **Transformers**: JSON automático

### MockApiService
Creamos un servicio mock completo para:
- Desarrollo sin backend disponible
- Testing más fácil con datos predecibles
- Delays simulados para UX realista
- Fácil toggle para producción con `useMockApi` flag

## Almacenamiento

### flutter_secure_storage
Para tokens sensibles usamos secure storage:
- Keychain en iOS
- Keystore en Android
- Encriptación transparente

## UI/UX

### Material 3
Aprovechamos Material 3 para:
- ColorScheme dinámico
- Elevated surfaces
- Tokens de diseño consistentes

### Temas
Soporte completo light/dark con:
- Paleta de colores personalizada
- Estados semánticos (error, warning, success)
- Colores específicos por feature (cameraStatus, alertPriority)

## Decisiones de MVP

### Placeholders
Algunas features son placeholders:

1. **Streaming de video**: Requiere integración HLS/RTSP (complejo)
2. **Notificaciones push**: Requiere FCM setup (backend dependency)
3. **Mapa**: Requiere Google Maps API key
4. **Admin panel**: Fuera de scope MVP

### Simplificaciones
- Sin persistencia local extensa (solo tokens)
- Sin modo offline completo
- Sin analytics
- Sin crash reporting

## Performance

### Optimizaciones implementadas
- `cached_network_image` para thumbnails
- `ListView.builder` para listas largas
- `const` constructors donde es posible
- Providers con `family` para parametrización eficiente

## Testing

Estructura preparada para:
- Unit tests de repositorios (mockeable)
- Widget tests de componentes
- Integration tests de flujos completos

## Seguridad

- Tokens en secure storage
- No hardcoded secrets
- Headers de autenticación en interceptor
- Refresh token automático

## Escalabilidad futura

El código está preparado para:
- Agregar nuevos features sin modificar existentes
- Cambiar de mock a API real con minimal changes
- Agregar analytics/crash reporting
- Internacionalización (ya usa `intl`)
- Multi-tenant (estructura por rol)
