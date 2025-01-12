import 'package:flutter/material.dart';

class AdminCommentDialog extends StatefulWidget {
  final String? initialComment;
  final Function(String) onSubmit;

  const AdminCommentDialog({
    super.key,
    this.initialComment,
    required this.onSubmit,
  });

  @override
  State<AdminCommentDialog> createState() => _AdminCommentDialogState();
}

class _AdminCommentDialogState extends State<AdminCommentDialog> {
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Admin Comment'),
      content: TextFormField(
        controller: _commentController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Enter your comment here...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit(_commentController.text.trim());
            Navigator.pop(context);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
