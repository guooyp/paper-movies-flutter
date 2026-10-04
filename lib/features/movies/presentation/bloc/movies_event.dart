part of 'movies_bloc.dart';

sealed class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load, retry and pull-to-refresh all use this event.
class MoviesRequested extends MoviesEvent {
  const MoviesRequested();
}

class SearchChanged extends MoviesEvent {
  const SearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class RatingSelected extends MoviesEvent {
  const RatingSelected(this.category);

  final RatingCategory category;

  @override
  List<Object?> get props => [category];
}
