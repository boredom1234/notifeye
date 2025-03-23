import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';

class NewsData {
  String? title;
  String? author;
  String? content;
  String? urlToImage;
  String? date;
  String? description;

  NewsData({
    this.title,
    this.author,
    this.content,
    this.date,
    this.urlToImage,
    this.description,
  });

  factory NewsData.fromJson(Map<String, dynamic> json) {
    return NewsData(
      title: json['title'] ?? 'No Title',
      author: json['author'] ?? 'Unknown Author',
      content: json['content'] ?? 'No Content Available',
      date: json['publishedAt'] ?? DateTime.now().toString(),
      urlToImage: json['urlToImage'] ?? 'https://via.placeholder.com/300',
      description: json['description'] ?? 'No description available',
    );
  }

  static Future<List<NewsData>> fetchBreakingNews() async {
    List<NewsData> breakingNewsData = [];
    int maxRetries = 3;
    int currentTry = 0;

    while (currentTry < maxRetries) {
      try {
        NewsAPI newsAPI = NewsAPI('9b47739bb08c4851b5431147f28ce1bd');
        print('Fetching breaking news (attempt ${currentTry + 1})...');

        List<Article> articles = await newsAPI.getTopHeadlines(
          country: 'in',
          pageSize: 10, // Limit to 10 articles
        );

        print('Received ${articles.length} articles');

        if (articles.isEmpty) {
          throw Exception('No articles returned from the API');
        }

        breakingNewsData = articles.map((article) {
          return NewsData(
            title: article.title ?? 'No Title',
            author: article.author ?? 'Unknown Author',
            content: article.content ?? 'No Content Available',
            date: article.publishedAt ?? DateTime.now().toString(),
            urlToImage: article.urlToImage ??
                'https://via.placeholder.com/300x200?text=No+Image',
            description: article.description ?? 'No description available',
          );
        }).toList();

        // If we get here, we successfully got the data
        return breakingNewsData;
      } catch (e) {
        print("Error fetching breaking news (attempt ${currentTry + 1}): $e");
        currentTry++;

        if (currentTry >= maxRetries) {
          throw Exception(
              'Failed to fetch news after $maxRetries attempts: $e');
        }

        // Wait before retrying
        await Future.delayed(Duration(seconds: 2));
      }
    }

    return breakingNewsData;
  }

  static Future<List<NewsData>> fetchRecentNews() async {
    List<NewsData> recentNewsData = [];
    int maxRetries = 3;
    int currentTry = 0;

    while (currentTry < maxRetries) {
      try {
        NewsAPI newsAPI = NewsAPI('9b47739bb08c4851b5431147f28ce1bd');
        print('Fetching recent news (attempt ${currentTry + 1})...');

        List<Article> articles = await newsAPI.getEverything(
          query: 'india',
          pageSize: 10, // Limit to 10 articles
          sortBy: 'publishedAt',
        );

        print('Received ${articles.length} articles');

        if (articles.isEmpty) {
          throw Exception('No articles returned from the API');
        }

        recentNewsData = articles.map((article) {
          return NewsData(
            title: article.title ?? 'No Title',
            author: article.author ?? 'Unknown Author',
            content: article.content ?? 'No Content Available',
            date: article.publishedAt ?? DateTime.now().toString(),
            urlToImage: article.urlToImage ??
                'https://via.placeholder.com/300x200?text=No+Image',
            description: article.description ?? 'No description available',
          );
        }).toList();

        // If we get here, we successfully got the data
        return recentNewsData;
      } catch (e) {
        print("Error fetching recent news (attempt ${currentTry + 1}): $e");
        currentTry++;

        if (currentTry >= maxRetries) {
          throw Exception(
              'Failed to fetch news after $maxRetries attempts: $e');
        }

        // Wait before retrying
        await Future.delayed(Duration(seconds: 2));
      }
    }

    return recentNewsData;
  }
}
