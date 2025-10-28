import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/favourite_service.dart';
import '../services/movie_service.dart';

class FavouriteViewModel extends ChangeNotifier {
  final FavouriteService _favouriteService = FavouriteService();
  final MovieService _movieService = MovieService();

  List<Movie> _favouriteMovies = [];
  List<String> _favouriteIds = [];
  bool _isLoading = false;

  List<Movie> get favouriteMovies => _favouriteMovies;
  bool get isLoading => _isLoading;

  Future<void> loadFavourites() async {
    _isLoading = true;
    notifyListeners();
    _favouriteIds = await _favouriteService.getFavouriteIds();
    List<Movie> tempFavourites = [];

    for (String id in _favouriteIds) {
      try {
        Movie movie = await _movieService.fetchMovieDetail(id);
        if (movie.id != '0') {
          tempFavourites.add(movie);
        }
      } catch (e) {
        print("Error fetching favourite movie detail for ID $id: $e");
      }
    }
    _favouriteMovies = tempFavourites;
    _isLoading = false;
    notifyListeners();
  }

  bool isFavourite(String movieId) {
    return _favouriteIds.contains(movieId);
  }

  Future<void> toggleFavourite(Movie movie) async {
    final movieId = movie.id;
    if (isFavourite(movieId)) {
      await _favouriteService.removeFavourite(movieId);
      _favouriteIds.remove(movieId);
      _favouriteMovies.removeWhere((m) => m.id == movieId);
    } else {
      await _favouriteService.addFavourite(movieId);
      _favouriteIds.add(movieId);
      _favouriteMovies.add(movie);
    }
    notifyListeners();
  }
}
