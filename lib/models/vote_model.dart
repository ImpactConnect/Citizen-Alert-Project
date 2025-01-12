enum VoteType { upvote, downvote }

class VoteModel {
  final String id;
  final String reportId;
  final String userId;
  final VoteType type;
  final DateTime createdAt;

  const VoteModel({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'report_id': reportId,
      'user_id': userId,
      'type': type.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VoteModel.fromMap(Map<String, dynamic> map) {
    return VoteModel(
      id: map['id'],
      reportId: map['report_id'],
      userId: map['user_id'],
      type: VoteType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
