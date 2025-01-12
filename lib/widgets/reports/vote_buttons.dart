import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vote_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/report_service.dart';

class VoteButtons extends StatefulWidget {
  final String reportId;

  const VoteButtons({
    super.key,
    required this.reportId,
  });

  @override
  State<VoteButtons> createState() => _VoteButtonsState();
}

class _VoteButtonsState extends State<VoteButtons> {
  final _reportService = ReportService();
  VoteType? _userVote;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserVote();
  }

  Future<void> _loadUserVote() async {
    final user = context.read<AuthProvider>().user;
    if (user != null && !user.isGuest) {
      try {
        final vote =
            await _reportService.getUserVote(widget.reportId, user.uid);
        if (mounted) {
          setState(() => _userVote = vote);
        }
      } catch (e) {
        debugPrint('Error loading user vote: $e');
      }
    }
  }

  Future<void> _handleVote(VoteType type) async {
    final user = context.read<AuthProvider>().user;
    if (user == null || user.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to vote')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_userVote == type) {
        await _reportService.removeVote(widget.reportId, user.uid);
        setState(() => _userVote = null);
      } else {
        await _reportService.addVote(widget.reportId, user.uid, type);
        setState(() => _userVote = type);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: _reportService.getVoteCounts(widget.reportId),
      builder: (context, snapshot) {
        final votes = snapshot.data ?? {'upvotes': 0, 'downvotes': 0};
        final score = votes['upvotes']! - votes['downvotes']!;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _userVote == VoteType.upvote
                    ? Icons.arrow_upward
                    : Icons.arrow_upward_outlined,
                color: _userVote == VoteType.upvote ? Colors.green : null,
              ),
              onPressed: _isLoading ? null : () => _handleVote(VoteType.upvote),
            ),
            Text(
              score.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: Icon(
                _userVote == VoteType.downvote
                    ? Icons.arrow_downward
                    : Icons.arrow_downward_outlined,
                color: _userVote == VoteType.downvote ? Colors.red : null,
              ),
              onPressed:
                  _isLoading ? null : () => _handleVote(VoteType.downvote),
            ),
          ],
        );
      },
    );
  }
}
