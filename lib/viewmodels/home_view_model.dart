import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieService _service = MovieService();
  List<Movie> _masterMovieList = [];

  List<Movie> _nowShowing = [];
  List<Movie> _trending = [];
  List<Movie> _topRated = [];
  bool _isLoading = true;
  String _selectedGenre = 'All';

  List<Movie> get nowShowing => _nowShowing;
  List<Movie> get trending => _trending;
  List<Movie> get topRated => _topRated;
  bool get isLoading => _isLoading;
  String get selectedGenre => _selectedGenre;

  Future<void> loadHomePageData() async {
    if (_masterMovieList.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      _masterMovieList = await _service.fetchAllMovies();
      _filterMovies();
    } catch (e) {
      print('Error loading movies in HomeViewModel: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateSelectedGenre(String genre) {
    _selectedGenre = genre;
    _filterMovies();
  }

  void _filterMovies() {
    List<Movie> filteredByGenre;

    if (_selectedGenre == 'All') {
      filteredByGenre = List.from(_masterMovieList);
    } else {
      filteredByGenre = _masterMovieList.where((movie) {
        return movie.genre.any((g) => g.toLowerCase() == _selectedGenre.toLowerCase());
      }).toList();
    }

    _nowShowing = filteredByGenre.where((m) =>
      m.releaseDate.contains('2024') || m.releaseDate.contains('2023')
    ).take(5).toList();

    _trending = filteredByGenre.where((m) =>
      m.rating >= 8.0 && m.rating <= 8.8
    ).take(5).toList();

    _topRated = filteredByGenre.where((m) =>
      m.rating > 8.0
    ).take(5).toList();

    notifyListeners();
  }

  void resetHomeFilter() {
    if (_selectedGenre == 'All') return;
    _selectedGenre = 'All';
    _filterMovies();
  }
}