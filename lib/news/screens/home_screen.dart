import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:crime/news/models/news_model.dart';
import 'package:crime/news/components/breaking_news_card.dart';
import 'package:crime/news/components/news_list_tile.dart';
import 'package:crime/utils/bottom_navigation.dart';
import 'package:crime/utils/custom_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Home Page'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Breaking News",
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              FutureBuilder<List<NewsData>>(
                future: NewsData.fetchBreakingNews(),
                builder: (context, breakingNewsSnapshot) {
                  if (breakingNewsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (breakingNewsSnapshot.hasError) {
                    return Text('Error: ${breakingNewsSnapshot.error}');
                  } else if (!breakingNewsSnapshot.hasData ||
                      breakingNewsSnapshot.data!.isEmpty) {
                    return Text('No breaking news available');
                  } else {
                    return Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: breakingNewsSnapshot.data!.length,
                          itemBuilder: (context, index, id) => BreakingNewsCard(
                              breakingNewsSnapshot.data![index]),
                          options: CarouselOptions(
                            aspectRatio: 16 / 9,
                            enableInfiniteScroll: false,
                            enlargeCenterPage: true,
                          ),
                        ),
                        const SizedBox(
                          height: 40.0,
                        ),
                        const Text(
                          "Recent News",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        FutureBuilder<List<NewsData>>(
                          future: NewsData.fetchRecentNews(),
                          builder: (context, recentNewsSnapshot) {
                            if (recentNewsSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (recentNewsSnapshot.hasError) {
                              return Text('Error: ${recentNewsSnapshot.error}');
                            } else if (!recentNewsSnapshot.hasData ||
                                recentNewsSnapshot.data!.isEmpty) {
                              return const Text('No recent news available');
                            } else {
                              return Column(
                                children: recentNewsSnapshot.data!
                                    .map((e) => NewsListTile(e))
                                    .toList(),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        defaultSelectedIndex: 2,
      ),
    );
  }
}
