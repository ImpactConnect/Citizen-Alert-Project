import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comment_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/report_service.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsSection extends StatefulWidget {
  final String reportId;

  const CommentsSection({
    super.key,
    required this.reportId,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final _commentController = TextEditingController();
  final _reportService = ReportService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = context.read<AuthProvider>().user!;
    setState(() => _isSubmitting = true);

    try {
      final comment = CommentModel(
        id: const Uuid().v4(),
        reportId: widget.reportId,
        userId: user.uid,
        userDisplayName: user.displayName ?? 'User',
        userAvatarUrl: user.avatarUrl,
        content: content,
        createdAt: DateTime.now(),
      );

      await _reportService.addComment(comment);
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting comment: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isGuest = user?.isGuest ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Discussion',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        StreamBuilder<List<CommentModel>>(
          stream: _reportService.getComments(widget.reportId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final comments = snapshot.data!;
            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return _CommentTile(
                      comment: comment,
                      currentUserId: user?.uid,
                      onDelete: () async {
                        try {
                          await _reportService.deleteComment(comment.id);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error deleting comment: $e'),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
                if (!isGuest) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          onPressed: _isSubmitting ? null : _submitComment,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final String? currentUserId;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAuthor = currentUserId == comment.userId;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: comment.userAvatarUrl != null
            ? NetworkImage(comment.userAvatarUrl!)
            : null,
        child: comment.userAvatarUrl == null
            ? Text(comment.userDisplayName[0].toUpperCase())
            : null,
      ),
      title: Row(
        children: [
          Text(
            comment.userDisplayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            timeago.format(comment.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      subtitle: Text(comment.content),
      trailing: isAuthor
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            )
          : null,
    );
  }
}
