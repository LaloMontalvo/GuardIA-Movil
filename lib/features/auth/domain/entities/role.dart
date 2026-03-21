/// Roles de usuario en la aplicación
enum Role {
  user,
  operator,
  admin;

  String get displayName {
    switch (this) {
      case Role.user:
        return 'Usuario';
      case Role.operator:
        return 'Operador';
      case Role.admin:
        return 'Administrador';
    }
  }

  bool get canManageCameras => this == Role.admin;
  bool get canManageUsers => this == Role.admin;
  bool get canCloseAlerts => this == Role.admin || this == Role.operator;
  bool get canExportEvidence => this == Role.admin || this == Role.operator;
  bool get canEditConfig => this == Role.admin;
  bool get canViewReports => this == Role.admin || this == Role.operator;

  static Role fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return Role.admin;
      case 'operator':
      case 'operador':
        return Role.operator;
      case 'user':
      case 'usuario':
      default:
        return Role.user;
    }
  }
}
