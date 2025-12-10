import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'widget/movie_card_widget.dart';
import 'movie_detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  static const routeName = '/category-list';

  // Model data untuk halaman ini
  final String title;
  final List<Movie> movies;

  const CategoryScreen({super.key, required this.title, required this.movies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: movies.isEmpty
          ? const Center(
              child: Text(
                'No movies found in this category.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: movies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return GestureDetector(
                  onTap: () {
                    // Navigasi ke detail film
                    Navigator.pushNamed(
                      context,
                      MovieDetailScreen.routeName,
                      arguments: movie.id,
                    );
                  },
                  child: MovieCardWidget(movie: movie, isLargeCard: false),
                );
              },
            ),
    );
  }
}