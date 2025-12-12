import '../constants.dart';
import '../services/movie_service.dart';

class Movie {
  final String id;
  final String title;
  final String releaseDate;
  final List<String> genre;
  final double rating;
  final String posterUrl;

  final String? summary;
  final String? duration;
  final String? director;
  final List<String>? cast;
  final String? trailerKey; // <-- NEW

  Movie({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.genre,
    required this.rating,
    required this.posterUrl,
    this.summary,
    this.duration,
    this.director,
    this.cast,
    this.trailerKey, // <-- NEW
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> genreNames = [];

    if (json.containsKey('genre_ids') && json['genre_ids'] is List) {
      List<int> genreIds = List<int>.from(json['genre_ids']);

      for (int id in genreIds) {
        String? name = MovieService.genreMap[id];
        if (name != null) {
          genreNames.add(name);
        }
      }
      if (genreNames.isEmpty) genreNames.add('N/A');
    } else if (json.containsKey('genres') && json['genres'] is List) {
      genreNames = List<String>.from(
        json['genres'].map((g) => g['name'].toString()),
      );
    }

    return Movie(
      id: json['id'].toString(),
      title: json['title'] as String,
      releaseDate: json['release_date'] ?? 'N/A',
      genre: genreNames,
      rating: (json['vote_average'] as num).toDouble(),
      posterUrl: json['poster_path'] != null
          ? '$kTmdbImagePath${json['poster_path']}'
          : '',
      summary: json['overview'] as String?,
      director: json['director'] as String?,
      cast: json['cast'] is List ? List<String>.from(json['cast']) : null,
      duration: json['runtime'] != null ? '${json['runtime']}m' : null,
      trailerKey: json['trailerKey'] as String?,
    );
  }
}
