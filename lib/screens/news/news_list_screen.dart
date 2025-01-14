import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/news_model.dart';
import '../../services/news_service.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import '../explore/explore_screen.dart';
import '../profile/profile_screen.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({Key? key}) : super(key: key);

  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final NewsService _newsService = NewsService();
  List<NewsModel> _newsList = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _selectedIndex = 1; // News page index
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchNews();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final news = await _newsService.fetchNews(page: _currentPage);
      setState(() {
        _newsList.addAll(news);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load news: $e')),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _currentPage++;
      _fetchNews();
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        // Already on News page
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ExploreScreen()),
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest News & Updates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement news search functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _newsList.clear();
            _currentPage = 1;
          });
          await _fetchNews();
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _newsList.length + 1,
          itemBuilder: (context, index) {
            if (index == _newsList.length) {
              return _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink();
            }

            final news = _newsList[index];
            return NewsListItem(
              news: news,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewsDetailScreen(newsId: news.id),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class NewsListItem extends StatelessWidget {
  final NewsModel news;
  final VoidCallback onTap;

  const NewsListItem({
    Key? key,
    required this.news,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: news.imageUrl.isNotEmpty
            ? Image.network(
                news.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
            : null,
        title: Text(
          news.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.source,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              _formatDate(news.publishedAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
