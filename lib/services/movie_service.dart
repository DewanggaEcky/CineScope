import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/movie.dart';

class MovieService {
  final String _jsonPath = 'assets/data/movies.json';

  Future<List<Movie>> _loadAndParseMovies() async {
    try {
      final jsonString = await rootBundle.loadString(_jsonPath);
      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList
          .map((data) => Movie.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading or parsing JSON: $e');
      return [];
    }
  }

  Future<List<Movie>> fetchAllMovies() async {
    await Future.delayed(const Duration(seconds: 1));
    return await _loadAndParseMovies();
  }

  Future<Movie> fetchMovieDetail(String id) async {
    final List<Movie> allMovies = await _loadAndParseMovies();
    return allMovies.firstWhere(
      (movie) => movie.id == id,
      orElse: () => Movie(
        id: '0',
        title: 'Not Found',
        releaseDate: '',
        genre: [],
        rating: 0.0,
        posterUrl: '',
        summary: '',
        duration: '0h 0m',
        director: 'Unknown',
        cast: ['N/A'],
      ),
    );
  }
}
