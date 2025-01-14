import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/news_model.dart';

class NewsService {
  // Dummy news data for demonstration
  final List<NewsModel> _dummyNews = [
    NewsModel(
      id: '1',
      title: 'New Emergency Response Protocol Launched',
      content: 'The city has introduced a comprehensive emergency response protocol to improve rapid reaction times and coordination between different emergency services. This new system integrates advanced communication technologies and real-time tracking to ensure faster and more efficient emergency responses.',
      imageUrl: 'https://example.com/emergency-response.jpg',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      source: 'City Emergency Department',
      tags: ['emergency', 'safety', 'technology'],
    ),
    NewsModel(
      id: '2',
      title: 'Community Safety Workshop This Weekend',
      content: 'Join us for a free community safety workshop this weekend. Learn essential safety skills, emergency preparedness techniques, and connect with local safety experts. The workshop will cover topics like first aid, emergency communication, and community response strategies.',
      imageUrl: 'https://example.com/safety-workshop.jpg',
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      source: 'Community Safety Council',
      tags: ['workshop', 'safety', 'community'],
    ),
    NewsModel(
      id: '3',
      title: 'Smart City Infrastructure Upgrades Announced',
      content: 'The city council has approved a major infrastructure upgrade project focusing on smart city technologies. The project includes installing advanced traffic management systems, IoT-enabled public utilities, and enhanced digital communication networks to improve urban living.',
      imageUrl: 'https://example.com/smart-city.jpg',
      publishedAt: DateTime.now().subtract(const Duration(days: 7)),
      source: 'City Planning Department',
      tags: ['infrastructure', 'technology', 'urban development'],
    ),
  ];

  Future<List<NewsModel>> fetchNews({int page = 1, int limit = 10}) async {
    // For demo purposes, return dummy news
    // In a real app, this would be an actual API call
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return paginated dummy news
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      
      return _dummyNews.sublist(
        startIndex, 
        endIndex > _dummyNews.length ? _dummyNews.length : endIndex
      );
    } catch (e) {
      print('Error fetching news: $e');
      return [];
    }
  }

  Future<NewsModel> fetchNewsDetails(String newsId) async {
    // For demo purposes, find news by ID in dummy data
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      return _dummyNews.firstWhere((news) => news.id == newsId);
    } catch (e) {
      print('Error fetching news details: $e');
      throw Exception('News not found');
    }
  }
}
