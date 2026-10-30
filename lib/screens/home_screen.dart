import 'package:flutter/material.dart';

import '../models/news_model.dart';
import '../sernices/news_service.dart';
import '../widgets/news_item.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
import 'menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<NewsModel>> news;

  int selectedCategory = 0;

  final List<String> categories = [
    'All',
    'Politics',
    'Sport',
    'Education',
    'AirPod',
  ];

  @override
  void initState() {
    super.initState();
    news = NewsService.getNews();
  }

  Future<void> changeCategory(int index) async {
    setState(() {
      selectedCategory = index;

      switch (categories[index]) {
        case 'All':
          news = NewsService.getNews();
          break;
        case 'Politics':
          news = NewsService.searchNews('politics');
          break;
        case 'Sport':
          news = NewsService.getNews(category: 'sports');
          break;
        case 'Education':
          news = NewsService.searchNews('education');
          break;
        case 'AirPod':
          news = NewsService.searchNews('AirPods');
          break;
      }
    });
  }

  void openPage(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        page,
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.15, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Widget buildNewsLoading() {
    return const Center(
      child: SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          color: Color(0xFFE53935),
          strokeCap: StrokeCap.round,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => openPage(const MenuScreen()),
          icon: const Icon(Icons.menu, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => openPage(const SearchScreen()),
            icon: const Icon(Icons.search, color: Colors.black),
          ),
          IconButton(
            onPressed: () =>
                openPage(const NotificationsScreen()),
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final selected = selectedCategory == index;

                return GestureDetector(
                  onTap: () => changeCategory(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFF5B33A)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFF5B33A)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // News title and Show More
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'News For You',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5276AE),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Show More',
                    style: TextStyle(
                      color: Color(0xFFF5B33A),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // News list and loading
          Expanded(
            child: FutureBuilder<List<NewsModel>>(
              future: news,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return buildNewsLoading();
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Could not load news'),
                        TextButton(
                          onPressed: () {
                            changeCategory(selectedCategory);
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final articles = snapshot.data ?? [];

                if (articles.isEmpty) {
                  return const Center(
                    child: Text('No News Found'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await changeCategory(selectedCategory);
                    await news;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      return NewsItem(news: articles[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


