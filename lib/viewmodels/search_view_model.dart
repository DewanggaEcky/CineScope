import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class SearchViewModel extends ChangeNotifier {
  final MovieService _service = MovieService();

  List<Movie> _masterMovieList = [];
  List<Movie> _filteredMovies = [];

  List<String> _availableGenres = ['All']; // <-- List untuk genre dinamis

  bool _isLoading = false;
  bool _isInitialLoadDone = false;
  String _searchQuery = '';
  String _selectedGenre = 'All';

  List<Movie> get filteredMovies => _filteredMovies;
  bool get isLoading => _isLoading;
  bool get isInitialLoadDone => _isInitialLoadDone;
  String get selectedGenre => _selectedGenre;
  String get searchQuery => _searchQuery;
  List<String> get availableGenres => _availableGenres;

  Future<void> fetchMasterList() async {
    if (_isInitialLoadDone && _searchQuery.isEmpty && _selectedGenre == 'All') {
      _applyLocalFilter();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _availableGenres = await _service.fetchGenres();
      if (!_availableGenres.contains(_selectedGenre)) {
        _selectedGenre = 'All';
      }

      if (_searchQuery.isEmpty) {
        if (!_isInitialLoadDone) {
          _masterMovieList = await _service.fetchPopularMovies();
        }
      } else {
        _masterMovieList = await _service.searchMovies(_searchQuery);
      }

      _applyLocalFilter();
      _isInitialLoadDone = true;
    } catch (e) {
      print('Error fetching data in SearchViewModel: $e');
      _masterMovieList = [];
      _filteredMovies = [];
      _availableGenres = ['All'];
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    fetchMasterList();
  }

  void updateSelectedGenre(String genre) {
    _selectedGenre = genre;
    fetchMasterList();
  }

  void _applyLocalFilter() {
    List<Movie> tempFilteredList;

    if (_selectedGenre == 'All') {
      tempFilteredList = _masterMovieList;
    } else {
      tempFilteredList = _masterMovieList.where((movie) {
        return movie.genre.any(
          (g) => g.toLowerCase() == _selectedGenre.toLowerCase(),
        );
      }).toList();
    }

    _filteredMovies = tempFilteredList;
  }

  void resetSearch() {
    _filteredMovies = [];
    _isInitialLoadDone = false;
    _searchQuery = '';
    _selectedGenre = 'All';
    notifyListeners();
  }
}
