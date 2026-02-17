/// Caso de evidencia: agrupa grabaciones/clips marcados
class EvidenceCase {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final List<String> recordingIds;
  final String createdBy;
  final String status; // open, closed, exported

  const EvidenceCase({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.recordingIds = const [],
    required this.createdBy,
    this.status = 'open',
  });

  int get clipCount => recordingIds.length;

  EvidenceCase copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    List<String>? recordingIds,
    String? createdBy,
    String? status,
  }) {
    return EvidenceCase(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      recordingIds: recordingIds ?? this.recordingIds,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
    );
  }
}
