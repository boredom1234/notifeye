import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';

class NewsData {
  String? title;
  String? author;
  String? content;
  String? urlToImage;
  String? date;

  NewsData({
    this.title,
    this.author,
    this.content,
    this.date,
    this.urlToImage,
  });

  static Future<List<NewsData>> fetchBreakingNews() async {
    List<NewsData> breakingNewsData = [];
    try {
      NewsAPI newsAPI = NewsAPI('9b47739bb08c4851b5431147f28ce1bd');
      List<Article> articles = await newsAPI.getTopHeadlines(country: 'in');
      breakingNewsData = articles
          .map((article) => NewsData(
                title: article.title,
                author: article.author,
                content: article.content,
                date: article.publishedAt,
                urlToImage: article.urlToImage,
              ))
          .toList();
    } catch (e) {
      print("Error fetching breaking news: $e");
    }
    return breakingNewsData;
  }

  static Future<List<NewsData>> fetchRecentNews() async {
    List<NewsData> recentNewsData = []; // Create a new list for recent news
    try {
      NewsAPI newsAPI = NewsAPI("9b47739bb08c4851b5431147f28ce1bd");
      List<Article> articles = await newsAPI.getTopHeadlines(country: 'in');
      recentNewsData = articles
          .map((article) => NewsData(
                title: article.title,
                author: article.author,
                content: article.content,
                date: article.publishedAt,
                urlToImage: article.urlToImage,
              ))
          .toList();
    } catch (e) {
      print("Error fetching recent news: $e");
    }
    return recentNewsData;
  }
}
