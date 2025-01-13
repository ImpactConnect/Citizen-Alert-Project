class CommentModel {
  final String id;
  final String reportId;
  final String userId;
  final String userDisplayName;
  final String? userAvatarUrl;
  final String content;
  final bool isAdminComment;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.content,
    this.isAdminComment = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'report_id': reportId,
      'user_id': userId,
      'user_display_name': userDisplayName,
      'user_avatar_url': userAvatarUrl,
      'content': content,
      'is_admin_comment': isAdminComment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'],
      reportId: map['report_id'],
      userId: map['user_id'],
      userDisplayName: map['user_display_name'],
      userAvatarUrl: map['user_avatar_url'],
      content: map['content'],
      isAdminComment: map['is_admin_comment'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  CommentModel copyWith({
    String? id,
    String? reportId,
    String? userId,
    String? userDisplayName,
    String? userAvatarUrl,
    String? content,
    bool? isAdminComment,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      isAdminComment: isAdminComment ?? this.isAdminComment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
