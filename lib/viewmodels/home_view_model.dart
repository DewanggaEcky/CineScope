import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieService _service = MovieService();

  List<String> _availableGenres = ['All'];

  List<Movie> _allNowShowing = [];
  List<Movie> _allTrending = [];
  List<Movie> _allTopRated = [];

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
  List<String> get availableGenres => _availableGenres;

  Future<void> loadHomePageData() async {
    if (_allNowShowing.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _availableGenres = await _service.fetchGenres();
      if (!_availableGenres.contains(_selectedGenre)) {
        _selectedGenre = 'All';
      }

      if (_allNowShowing.isEmpty) {
        _allNowShowing = await _service.fetchNowPlayingMovies();
        _allTrending = await _service.fetchPopularMovies();
        _allTopRated = await _service.fetchTopRatedMovies();
      }

      _filterMovies();
    } catch (e) {
      print('Error loading data in HomeViewModel: $e');
      _allNowShowing = [];
      _allTrending = [];
      _allTopRated = [];
      _nowShowing = [];
      _trending = [];
      _topRated = [];
      _availableGenres = ['All'];
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateSelectedGenre(String genre) {
    if (_selectedGenre == genre) return;

    _selectedGenre = genre;

    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      _filterMovies();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> resetHomeFilterAndRefresh() async {
    _selectedGenre = 'All';
    _allNowShowing = [];
    _allTrending = [];
    _allTopRated = [];

    await loadHomePageData();
  }

  void _filterMovies() {
    if (_selectedGenre == 'All') {
      _nowShowing = List.from(_allNowShowing);
      _trending = List.from(_allTrending);
      _topRated = List.from(_allTopRated);
    } else {
      _nowShowing = _allNowShowing.where((movie) {
        return movie.genre.any(
          (g) => g.toLowerCase() == _selectedGenre.toLowerCase(),
        );
      }).toList();

      _trending = _allTrending.where((movie) {
        return movie.genre.any(
          (g) => g.toLowerCase() == _selectedGenre.toLowerCase(),
        );
      }).toList();

      _topRated = _allTopRated.where((movie) {
        return movie.genre.any(
          (g) => g.toLowerCase() == _selectedGenre.toLowerCase(),
        );
      }).toList();
    }
  }

  void resetHomeFilter() {
    if (_selectedGenre == 'All') return;
    _selectedGenre = 'All';
    _filterMovies();
    notifyListeners();
  }
}