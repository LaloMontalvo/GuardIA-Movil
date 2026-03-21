# GuardIA Movil - Tech Stack

## Core Frameworks & Languages
- **Flutter**: UI Toolkit for building natively compiled applications.
- **Dart**: Programming language used for Flutter development.

## Architecture & State Management
- **Architecture**: Clean Architecture (Presentation, Domain, Data layers).
- **Riverpod** (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`): Reactive caching and state binding framework.
- **Freezed** (`freezed_annotation`, `freezed`): Code generation for immutable classes and unions.
- **JSON Serializable** (`json_annotation`, `json_serializable`): Code generation for JSON serialization/deserialization.

## Navigation
- **GoRouter** (`go_router`): Declarative routing package for Flutter.

## Networking & APIs
- **Dio** (`dio`): Powerful HTTP client for Dart.
- **Firebase**:
    - `firebase_core`: initialization.
    - `firebase_auth`: User authentication.
    - `cloud_firestore`: Cloud NoSQL database.

## Local Storage
- **Flutter Secure Storage** (`flutter_secure_storage`): Secure storage for sensitive data (tokens).
- **Shared Preferences** (`shared_preferences`): Persistent storage for simple data.

## Maps & Location
- **Flutter Map** (`flutter_map`): Versatile mapping package (OpenStreetMap).
- **LatLong2** (`latlong2`): Latitude and longitude calculations.
- **Geolocator** (`geolocator`): Geolocation services.
- **Permission Handler** (`permission_handler`): Handling runtime permissions.

## UI & Assets
- **Cupertino Icons** (`cupertino_icons`): iOS style icons.
- **FL Chart** (`fl_chart`): Chart library.
- **Smooth Page Indicator** (`smooth_page_indicator`): UI indicator for page views.
- **Cached Network Image** (`cached_network_image`): Image caching.
- **Intl** (`intl`): Internationalization and localization.

## Device Features
- **Image Picker** (`image_picker`): Gallery and camera image selection.
- **Share Plus** (`share_plus`): Content sharing.
- **Url Launcher** (`url_launcher`): Launching URLs in browser/apps.
- **Path Provider** (`path_provider`): Accessing filesystem paths.
- **Flutter Local Notifications** (`flutter_local_notifications`): displaying local notifications.

## Development Tools
- **Build Runner** (`build_runner`): Tool for running code generation.
- **Flutter Launcher Icons** (`flutter_launcher_icons`): Generating app icons.
- **Flutter Lints** (`flutter_lints`): Static analysis rules.
