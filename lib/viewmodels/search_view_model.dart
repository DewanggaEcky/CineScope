import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class SearchViewModel extends ChangeNotifier {
  final MovieService _service = MovieService();

  List<Movie> _masterMovieList = [];
  List<Movie> _filteredMovies = [];

  bool _isLoading = false;
  bool _hasSearched = false;
  String _searchQuery = '';
  String _selectedGenre = 'All';
  
  List<Movie> get filteredMovies => _filteredMovies;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  String get selectedGenre => _selectedGenre;

  Future<void> fetchMasterList() async {
    if (_masterMovieList.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();

    _masterMovieList = await _service.fetchAllMovies();
    _filteredMovies = [];

    _isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _filterMovies();
  }

  void updateSelectedGenre (String genre) {
    _selectedGenre = genre;
    _filterMovies();
  }

  void _filterMovies() {
    _isLoading = true;
    _hasSearched = true;
    notifyListeners();

    List<Movie> tempFilteredList;
    if(_selectedGenre == 'All') {
      tempFilteredList = _masterMovieList;
    } else {
      tempFilteredList = _masterMovieList.where((movie) {
        return movie.genre.any((g) => g.toLowerCase() == _selectedGenre.toLowerCase());
      }).toList();
    }

    if (_searchQuery.isEmpty) {
      _filteredMovies = tempFilteredList;
    }else {
      _filteredMovies = tempFilteredList.where((movie) {
        return movie.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  void resetSearch() {
    _filteredMovies = [];
    _hasSearched = false;
    _searchQuery = '';
    _selectedGenre = 'All';
    notifyListeners();
  }
}