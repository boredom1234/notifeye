import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:crime/news/models/news_model.dart';
import 'package:crime/news/components/breaking_news_card.dart';
import 'package:crime/news/components/news_list_tile.dart';
import 'package:crime/utils/bottom_navigation.dart';
import 'package:crime/utils/custom_widgets.dart';
import 'package:crime/utils/theme.dart';
import 'package:crime/service/global.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<NewsData>>? _recentNewsFuture;
  bool _isEmergencyMode = false;

  @override
  void initState() {
    super.initState();
    _refreshNews();
  }

  void _refreshNews() {
    setState(() {
      _recentNewsFuture = NewsData.fetchRecentNews();
    });
  }

  void _toggleEmergencyMode() {
    setState(() {
      _isEmergencyMode = !_isEmergencyMode;
    });
    if (_isEmergencyMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Emergency Mode Activated',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppTheme.error,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Deactivate',
            textColor: Colors.white,
            onPressed: _toggleEmergencyMode,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Home', style: AppTheme.titleLarge),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 2,
        centerTitle: true,
        actions: [
          if (_isEmergencyMode)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.emergency, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Emergency',
                    style: AppTheme.bodySmall.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshNews();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions Grid
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Actions",
                      style: AppTheme.headlineMedium.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildQuickActionCard(
                          icon: Icons.report_problem_outlined,
                          title: "Report Crime",
                          subtitle: "File a new crime report",
                          onTap: () =>
                              Navigator.pushNamed(context, '/crimeReport'),
                        ),
                        _buildQuickActionCard(
                          icon: Icons.location_on_outlined,
                          title: "Nearby Alerts",
                          subtitle: "View crime alerts in your area",
                          onTap: () =>
                              Navigator.pushNamed(context, '/crimeAlert'),
                        ),
                        _buildQuickActionCard(
                          icon: Icons.emergency_outlined,
                          title: "Emergency Mode",
                          subtitle:
                              _isEmergencyMode ? "Deactivate" : "Activate",
                          color: _isEmergencyMode ? AppTheme.error : null,
                          onTap: _toggleEmergencyMode,
                        ),
                        _buildQuickActionCard(
                          icon: Icons.people_outline,
                          title: "Emergency Contacts",
                          subtitle: "Manage your contacts",
                          onTap: () =>
                              Navigator.pushNamed(context, '/manageContact'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Safety Tips Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tips_and_updates_outlined,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Safety Tip of the Day",
                              style: AppTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Always be aware of your surroundings and trust your instincts. If something doesn't feel right, it probably isn't.",
                          style: AppTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/helpCenter'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "More Safety Tips",
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Recent News Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  "Recent News",
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              FutureBuilder<List<NewsData>>(
                future: _recentNewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading news: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refreshNews,
                            style: AppTheme.primaryButtonStyle,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.info,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recent news available',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.info,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refreshNews,
                            style: AppTheme.primaryButtonStyle,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: snapshot.data!
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: NewsListTile(e),
                                ))
                            .toList(),
                      ),
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
      floatingActionButton: _isEmergencyMode
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Implement emergency action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Emergency services contacted',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.error,
                  ),
                );
              },
              backgroundColor: AppTheme.error,
              icon: const Icon(Icons.emergency),
              label: const Text('Emergency'),
            )
          : null,
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color ?? AppTheme.primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTheme.titleSmall.copyWith(
                  color: color ?? AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTheme.bodySmall.copyWith(
                  color: color != null
                      ? color.withOpacity(0.8)
                      : AppTheme.textLightColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
