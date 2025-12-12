import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../constants.dart';

class MovieService {
  static Map<int, String> _genreMap = {};
  static Map<int, String> get genreMap => _genreMap;

  Future<List<Movie>> _fetchMoviesFromApi(
    String endpoint, {
    int page = 1,
  }) async {
    final url = Uri.parse(
      '$kTmdbBaseUrl$endpoint?api_key=$kTmdbApiKey&page=$page',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> results = jsonResponse['results'];

        return results
            .map((data) => Movie.fromJson(data as Map<String, dynamic>))
            .where((movie) => movie.posterUrl.isNotEmpty)
            .toList();
      } else {
        throw Exception(
          'Failed to load movies from $endpoint: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching movies from $endpoint: $e');
    }
  }

  Future<List<Movie>> fetchPopularMovies() async {
    List<Movie> allMovies = [];
    for (int i = 1; i <= 10; i++) {
      allMovies.addAll(await _fetchMoviesFromApi(kPopularEndpoint, page: i));
    }
    return allMovies.toSet().toList();
  }

  Future<List<Movie>> fetchNowPlayingMovies() async {
    return await _fetchMoviesFromApi(kNowPlayingEndpoint, page: 1);
  }

  Future<List<Movie>> fetchTopRatedMovies() async {
    List<Movie> allMovies = [];
    for (int i = 1; i <= 10; i++) {
      allMovies.addAll(await _fetchMoviesFromApi(kTopRatedEndpoint, page: i));
    }
    return allMovies.toSet().toList();
  }

  Future<List<String>> fetchGenres() async {
    if (_genreMap.isNotEmpty) {
      List<String> genreNames = _genreMap.values.toList();
      genreNames.insert(0, 'All');
      return genreNames;
    }

    final url = Uri.parse(
      '$kTmdbBaseUrl/genre/movie/list?api_key=$kTmdbApiKey',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> genreList = jsonResponse['genres'];

        _genreMap = Map.fromIterable(
          genreList,
          key: (genre) => genre['id'] as int,
          value: (genre) => genre['name'] as String,
        );

        List<String> genreNames = _genreMap.values.toList();
        genreNames.insert(0, 'All');
        return genreNames;
      } else {
        throw Exception('Failed to load genres: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching genres: $e');
      return ['All'];
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.parse(
      '$kTmdbBaseUrl$kSearchEndpoint?api_key=$kTmdbApiKey&query=$query',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> results = jsonResponse['results'];
        return results
            .map((data) => Movie.fromJson(data as Map<String, dynamic>))
            .where((movie) => movie.posterUrl.isNotEmpty)
            .toList();
      } else {
        throw Exception(
          'Failed to search movies. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error searching movies: $e');
    }
  }

  Future<String?> _fetchMovieTrailerKey(String movieId) async {
    final url = Uri.parse(
      '$kTmdbBaseUrl/movie/$movieId/videos?api_key=$kTmdbApiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> results = jsonResponse['results'];

        if (results.isEmpty) return null;

        final trailer = results.firstWhere(
          (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
          orElse: () => null,
        );

        if (trailer != null) {
          return trailer['key'] as String;
        }

        final anyYoutubeVideo = results.firstWhere(
          (video) => video['site'] == 'YouTube',
          orElse: () => null,
        );

        if (anyYoutubeVideo != null) {
          return anyYoutubeVideo['key'] as String;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching trailer for $movieId: $e');
      return null;
    }
  }

  Future<Movie> fetchMovieDetail(String id) async {
    final url = Uri.parse('$kTmdbBaseUrl/movie/$id?api_key=$kTmdbApiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final creditsUrl = Uri.parse(
          '$kTmdbBaseUrl/movie/$id/credits?api_key=$kTmdbApiKey',
        );
        final creditsResponse = await http.get(creditsUrl);

        String director = 'N/A';
        List<String> cast = ['N/A'];

        if (creditsResponse.statusCode == 200) {
          final creditsJson = json.decode(creditsResponse.body);

          final crew = creditsJson['crew'] as List<dynamic>?;
          if (crew != null) {
            final directorData = crew.firstWhere(
              (c) => c['job'] == 'Director',
              orElse: () => null,
            );
            director = directorData != null ? directorData['name'] : 'N/A';
          }

          final castData = creditsJson['cast'] as List<dynamic>?;
          if (castData != null && castData.isNotEmpty) {
            cast = castData.take(3).map((c) => c['name'].toString()).toList();
          }
        }

        String? trailerKey = await _fetchMovieTrailerKey(id);
        
        return Movie.fromJson({
          ...jsonResponse,
          'director': director,
          'cast': cast,
          'trailerKey': trailerKey,
        });
      } else {
        throw Exception('Failed to load movie detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movie detail: $e');
    }
  }
}
