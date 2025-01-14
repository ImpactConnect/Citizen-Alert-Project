import 'package:flutter/material.dart';
import '../../models/news_model.dart';
import '../../services/news_service.dart';

class NewsDetailScreen extends StatefulWidget {
  final String newsId;

  const NewsDetailScreen({Key? key, required this.newsId}) : super(key: key);

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final NewsService _newsService = NewsService();
  NewsModel? _news;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNewsDetails();
  }

  Future<void> _fetchNewsDetails() async {
    try {
      final news = await _newsService.fetchNewsDetails(widget.newsId);
      setState(() {
        _news = news;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load news details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _news == null
              ? const Center(child: Text('News not found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_news!.imageUrl.isNotEmpty)
                        Image.network(
                          _news!.imageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _news!.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _news!.source,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  _formatDate(_news!.publishedAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const Divider(),
                            Text(
                              _news!.content,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            if (_news!.tags.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                children: _news!.tags.map((tag) {
                                  return Chip(
                                    label: Text(tag),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
