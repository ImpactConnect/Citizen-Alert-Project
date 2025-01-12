class CommentModel {
  final String id;
  final String reportId;
  final String userId;
  final String userDisplayName;
  final String? userAvatarUrl;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.content,
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
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
