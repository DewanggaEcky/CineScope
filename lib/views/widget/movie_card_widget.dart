import 'package:flutter/material.dart';
import '../../models/movie.dart';

class MovieCardWidget extends StatelessWidget {
  final Movie movie;
  final bool isLargeCard;

  const MovieCardWidget({
    super.key,
    required this.movie,
    required this.isLargeCard,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth = isLargeCard ? 180 : 150;

    return Container(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  movie.posterUrl,
                  height: isLargeCard ? 240 : 180,
                  width: cardWidth,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: isLargeCard ? 240 : 180,
                      width: cardWidth,
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(Icons.movie, color: Colors.white54),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        movie.rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            movie.releaseDate.substring(
              0,
              4,
            ),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
