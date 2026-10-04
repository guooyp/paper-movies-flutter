import '../entities/movie.dart';
import '../entities/rating_category.dart';

List<Movie> filterMovies(
  List<Movie> movies, {
  required String query,
  required RatingCategory category,
}) {
  final needle = query.trim().toLowerCase();
  return movies.where((movie) {
    if (movie.voteAverage < category.minRating) return false;
    return needle.isEmpty || movie.title.toLowerCase().contains(needle);
  }).toList();
}
