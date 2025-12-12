import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class MovieDetailViewModel extends ChangeNotifier {
  final MovieService _service = MovieService();

  Movie? _movie;
  List<Movie> _similarMovies = [];
  bool _isLoading = true;

  Movie? get movie => _movie;
  List<Movie> get similarMovies => _similarMovies;
  bool get isLoading => _isLoading;

  Future<void> fetchMovieDetail(String movieId) async {
    _isLoading = true;
    _movie = null;
    _similarMovies = [];
    notifyListeners();

    try {
      _movie = await _service.fetchMovieDetail(movieId);
      if (_movie != null) {
        List<Movie> allMovies = await _service.fetchPopularMovies();

        _similarMovies = allMovies
            .where((m) => m.id != movieId)
            .take(5)
            .toList();
      }
    } catch (e) {
      print('Error fetching movie detail: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
