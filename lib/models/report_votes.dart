// Create a new file for ReportVotes model
class ReportVotes {
  final int upvotes;
  final int downvotes;

  ReportVotes({required this.upvotes, required this.downvotes});

  // Optional: Add factory constructor for parsing from JSON if needed
  factory ReportVotes.fromJson(Map<String, dynamic> json) {
    return ReportVotes(
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
    );
  }
}
