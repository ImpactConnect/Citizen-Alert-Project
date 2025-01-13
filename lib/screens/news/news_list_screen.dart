import 'package:flutter/material.dart';
import '../../models/news_model.dart';
import '../../widgets/layout/base_layout.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual news data from your backend
    final news = [
      NewsModel(
        id: '1',
        title: 'New Emergency Response Protocol',
        content:
            'Updated guidelines for emergency response procedures have been implemented to ensure faster and more efficient handling of emergency situations. All citizens are advised to familiarize themselves with the new protocols.',
        category: 'Updates',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isImportant: true,
      ),
      // Add more news items...
    ];

    return BaseLayout(
      title: 'News & Updates',
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: news.length,
        itemBuilder: (context, index) {
          final item = news[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                // TODO: Navigate to news detail
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.category,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (item.isImportant) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.priority_high,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Important',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.8),
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      timeago.format(item.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
