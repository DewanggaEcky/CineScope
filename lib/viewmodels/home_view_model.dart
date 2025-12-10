import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieService _service = MovieService();

  List<String> _availableGenres = ['All'];

  List<Movie> _allNowShowing = []; // Data base sebelum difilter
  List<Movie> _allTrending = []; // Data base sebelum difilter
  List<Movie> _allTopRated = []; // Data base sebelum difilter

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
    // Hanya tampilkan loading penuh jika data base belum ada
    if (_allNowShowing.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      // 1. HARUS FETCH GENRES PERTAMA untuk mengisi Map di Service
      _availableGenres = await _service.fetchGenres();
      if (!_availableGenres.contains(_selectedGenre)) {
        _selectedGenre = 'All';
      }

      // 2. Ambil data film base (hanya jika belum pernah diambil)
      if (_allNowShowing.isEmpty) {
        _allNowShowing = await _service.fetchNowPlayingMovies();
        _allTrending = await _service.fetchPopularMovies();
        _allTopRated = await _service.fetchTopRatedMovies();
      }

      // 3. Terapkan filter genre ke daftar base
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

    // Jalankan filter movies di background (simulate delay for smooth UI)
    Future.delayed(const Duration(milliseconds: 300), () {
      _filterMovies();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> resetHomeFilterAndRefresh() async {
    // 1. Reset ke genre "All"
    _selectedGenre = 'All';

    // 2. Kosongkan data base agar fetch API ulang
    _allNowShowing = [];
    _allTrending = [];
    _allTopRated = [];

    // 3. Muat ulang data
    await loadHomePageData();
  }

  void _filterMovies() {
    if (_selectedGenre == 'All') {
      _nowShowing = List.from(_allNowShowing);
      _trending = List.from(_allTrending);
      _topRated = List.from(_allTopRated);
    } else {
      // Filter list base menggunakan Nama Genre yang LENGKAP
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