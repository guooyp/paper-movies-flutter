/// TMDB's movie genre ids. The discover response only carries ids, and this
/// list almost never changes, so it's cheaper than a second request.
const _movieGenres = {
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Science Fiction',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
};

/// Names for the ids we know. Unknown ids are dropped instead of shown raw.
List<String> genreNames(List<int> ids) => [
  for (final id in ids) ?_movieGenres[id],
];
