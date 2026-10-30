import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
class NewsService {
  static const String apiKey = 'd6fee27fd9ae4ec5bfddade7baef0539';
  static const int pageSize = 20;
  static Future<List<NewsModel>> getNews({
    String category = 'all',
    int page = 1,
  }) async {
    final Map<String, String> parameters = {
      'apiKey': apiKey,
      'country': 'us',
      'pageSize': '$pageSize',
      'page': '$page',
    };
    if (category != 'all') {
      parameters['category'] = category;
    }
    final url = Uri.https(
      'newsapi.org',
      '/v2/top-headlines',
      parameters,
    );
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load news: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    if (data['status'] != 'ok') {
      throw Exception(data['message'] ?? 'News API error');
    }
    final List articles = data['articles'];
    return articles
        .where((article) =>
    article['title'] != null &&
        article['title'] != '[Removed]')
        .map<NewsModel>((article) => NewsModel.fromJson(article))
        .toList();
  }
  static Future<List<NewsModel>> searchNews(
      String query, {
        int page = 1,
      }) async {
    final url = Uri.https(
      'newsapi.org',
      '/v2/everything',
      {
        'apiKey': apiKey,
        'q': query,
        'pageSize': '$pageSize',
        'page': '$page',
        'language': 'en',
        'sortBy': 'publishedAt',
      },
    );
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to search news: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    if (data['status'] != 'ok') {
      throw Exception(data['message'] ?? 'Search API error');
    }
    final List articles = data['articles'];
    return articles
        .where((article) =>
    article['title'] != null &&
        article['title'] != '[Removed]')
        .map<NewsModel>((article) => NewsModel.fromJson(article))
        .toList();
  }
}