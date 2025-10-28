class Movie {
  final String id;
  final String title;
  final String releaseDate;
  final List<String> genre;
  final double rating;
  final String posterUrl;
  final String summary;
  final String duration;
  final String director;
  final List<String> cast;

  Movie({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.genre,
    required this.rating,
    required this.posterUrl,
    required this.summary,
    required this.duration,
    required this.director,
    required this.cast,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> genreList = [];
    if (json['genre'] is List) {
      genreList = List<String>.from(json['genre'].map((item) => item.toString()));
    }

    List<String> castList = [];
    if (json['cast'] is List) {
      castList = List<String>.from(json['cast'].map((item) => item.toString()));
    }

    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      releaseDate: json['releaseDate'] as String,
      genre: genreList,
      rating: (json['rating'] as num).toDouble(),
      posterUrl: json['posterUrl'] as String,
      summary: json['summary'] as String,
      duration: json['duration'] as String,
      director: json['director'] as String,
      cast: castList,
    );
  }
}