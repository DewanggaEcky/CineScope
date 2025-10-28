import 'package:shared_preferences/shared_preferences.dart';

class FavouriteService {
  static const String _favouriteKey = 'favouriteMovies';

  Future<List<String>> getFavouriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favouriteKey) ?? [];
  }

  Future<void> _saveFavouriteIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favouriteKey, ids);
  }

  Future<void> addFavourite(String movieId) async {
    List<String> currentFavourites = await getFavouriteIds();
    if (!currentFavourites.contains(movieId)) {
      currentFavourites.add(movieId);
      await _saveFavouriteIds(currentFavourites);
    }
  }

  Future<void> removeFavourite(String movieId) async {
    List<String> currentFavourites = await getFavouriteIds();
    currentFavourites.remove(movieId);
    await _saveFavouriteIds(currentFavourites);
  }

  Future<bool> isFavourite(String movieId) async {
    List<String> currentFavourites = await getFavouriteIds();
    return currentFavourites.contains(movieId);
  }
}
