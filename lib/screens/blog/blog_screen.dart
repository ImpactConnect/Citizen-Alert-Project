import 'package:flutter/material.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Blog'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBlogPostCard(
            context,
            title: 'Community Safety Initiatives',
            excerpt: 'Learn about our latest community safety programs...',
            author: 'Admin',
            date: 'June 15, 2023',
          ),
          _buildBlogPostCard(
            context,
            title: 'Reporting Tips and Best Practices',
            excerpt: 'How to effectively report issues in your community...',
            author: 'Community Manager',
            date: 'June 10, 2023',
          ),
          _buildBlogPostCard(
            context,
            title: 'Citizen Engagement Success Stories',
            excerpt: 'Highlighting impactful community reports...',
            author: 'Community Team',
            date: 'June 5, 2023',
          ),
        ],
      ),
    );
  }

  Widget _buildBlogPostCard(
    BuildContext context, {
    required String title,
    required String excerpt,
    required String author,
    required String date,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              excerpt,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'By $author',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
