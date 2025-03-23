import 'package:flutter/material.dart';
import 'package:crime/news/models/news_model.dart';
import 'package:crime/news/screens/details_screen.dart';
import 'package:crime/utils/theme.dart';

class RecentNewsCard extends StatefulWidget {
  final NewsData data;

  const RecentNewsCard(this.data, {super.key});

  @override
  State<RecentNewsCard> createState() => _RecentNewsCardState();
}

class _RecentNewsCardState extends State<RecentNewsCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(widget.data),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.data.urlToImage!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      color: AppTheme.secondaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppTheme.secondaryColor,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.title!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.data.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: AppTheme.textColor.withOpacity(0.6),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.data.author!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textColor.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.access_time,
                          color: AppTheme.textColor.withOpacity(0.6),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.data.date!.substring(0, 10),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
