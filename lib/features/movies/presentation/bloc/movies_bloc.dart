import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/rating_category.dart';
import '../../domain/usecases/filter_movies.dart';
import '../../domain/usecases/get_movies.dart';

part 'movies_event.dart';
part 'movies_state.dart';

const searchDebounce = Duration(milliseconds: 300);

EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  MoviesBloc({required this._getMovies}) : super(const MoviesState()) {
    on<MoviesRequested>(_onRequested);
    on<SearchChanged>(_onSearchChanged, transformer: _debounce(searchDebounce));
    on<RatingSelected>(_onRatingSelected);
  }

  final GetMovies _getMovies;

  Future<void> _onRequested(
    MoviesRequested event,
    Emitter<MoviesState> emit,
  ) async {
    if (state.status == MoviesStatus.loading) return;

    emit(state.copyWith(status: MoviesStatus.loading));
    try {
      final movies = await _getMovies();
      emit(state.copyWith(status: MoviesStatus.success, movies: movies));
    } on Failure catch (failure) {
      // Keep whatever we already had so a failed refresh doesn't wipe the list.
      emit(state.copyWith(status: MoviesStatus.failure, failure: failure));
    } catch (error, stackTrace) {
      // Without this a surprise exception would leave the screen loading forever.
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: MoviesStatus.failure,
          failure: const UnknownFailure(),
        ),
      );
    }
  }

  void _onSearchChanged(SearchChanged event, Emitter<MoviesState> emit) {
    emit(state.copyWith(query: event.query, failure: state.failure));
  }

  void _onRatingSelected(RatingSelected event, Emitter<MoviesState> emit) {
    emit(state.copyWith(category: event.category, failure: state.failure));
  }
}
