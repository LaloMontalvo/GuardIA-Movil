/// Ticket de soporte
class SupportTicket {
  final String id;
  final String subject;
  final String description;
  final String status; // open, in_progress, resolved, closed
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> attachments;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.description,
    this.status = 'open',
    required this.createdAt,
    this.updatedAt,
    this.attachments = const [],
  });

  String get statusDisplayName {
    switch (status) {
      case 'open':
        return 'Abierto';
      case 'in_progress':
        return 'En progreso';
      case 'resolved':
        return 'Resuelto';
      case 'closed':
        return 'Cerrado';
      default:
        return status;
    }
  }
}
