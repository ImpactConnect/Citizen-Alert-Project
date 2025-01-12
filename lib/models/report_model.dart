enum ReportCategory {
  infrastructure,
  environment,
  utilities,
  emergency,
  general,
}

enum ReportStatus {
  pending,
  inProgress,
  resolved,
  rejected,
}

class ReportModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String location;
  final ReportCategory category;
  final ReportStatus status;
  final String priority;
  final List<String> mediaUrls;
  final String? videoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReportModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    this.status = ReportStatus.pending,
    this.priority = 'medium',
    this.mediaUrls = const [],
    this.videoUrl,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'location': location,
      'category': category.toString().split('.').last,
      'status': status.toString().split('.').last,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'media_urls': mediaUrls,
      'video_url': videoUrl,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      category: ReportCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      priority: map['priority'],
      mediaUrls: List<String>.from(map['media_urls'] ?? []),
      videoUrl: map['video_url'],
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  ReportModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? location,
    ReportCategory? category,
    ReportStatus? status,
    String? priority,
    List<String>? mediaUrls,
    String? videoUrl,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
