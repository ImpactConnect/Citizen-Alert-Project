import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../models/news_model.dart';
import '../../news/news_list_screen.dart';

class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual news data from your backend
    final dummyNews = [
      NewsModel(
        id: '1',
        title: 'New Emergency Response Protocol',
        content: 'Updated guidelines for emergency response procedures...',
        category: 'Updates',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isImportant: true,
      ),
      NewsModel(
        id: '2',
        title: 'Community Safety Workshop',
        content: 'Join us for a free safety workshop this weekend...',
        category: 'Events',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NewsModel(
        id: '3',
        title: 'App Maintenance Notice',
        content: 'Scheduled maintenance on Sunday, 2 AM...',
        category: 'System',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'News & Updates',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewsListScreen()),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: dummyNews.length,
            itemBuilder: (context, index) {
              final news = dummyNews[index];
              return _NewsCard(news: news);
            },
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsModel news;

  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: Show news detail
        },
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: news.isImportant
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.primary.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      news.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (news.isImportant) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.priority_high,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                news.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                news.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                timeago.format(news.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
