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

    // Perubahan: Menggunakan Image.network dan penanganan loading/error
    final bool isNetworkImage = movie.posterUrl.isNotEmpty;
    final String imageUrl = movie.posterUrl;

    return Container(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: isNetworkImage
                    ? Image.network(
                        // <-- Perubahan: Menggunakan Image.network
                        imageUrl,
                        height: isLargeCard ? 240 : 180,
                        width: cardWidth,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          // Indikator loading (Circular ProgressIndicator)
                          return Container(
                            height: isLargeCard ? 240 : 180,
                            width: cardWidth,
                            color: Colors.grey.shade900,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                strokeWidth: 2.0,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Error State/Placeholder
                          return Container(
                            height: isLargeCard ? 240 : 180,
                            width: cardWidth,
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: Icon(Icons.movie, color: Colors.white54),
                            ),
                          );
                        },
                      )
                    : Container(
                        // Fallback for empty URL (no poster path)
                        height: isLargeCard ? 240 : 180,
                        width: cardWidth,
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: Icon(Icons.movie, color: Colors.white54),
                        ),
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
                        movie.rating.toStringAsFixed(
                          1,
                        ), // Menampilkan 1 desimal
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
            movie.releaseDate.length >= 4
                ? movie.releaseDate.substring(0, 4)
                : 'N/A',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
