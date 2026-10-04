import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/movie.dart';
import '../bloc/movies_bloc.dart';
import 'movie_detail_screen.dart';
import '../widgets/error_view.dart';
import '../widgets/movie_card.dart';
import '../widgets/rating_chips.dart';
import '../widgets/search_field.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  bool _searching = false;

  void _toggleSearch() {
    setState(() => _searching = !_searching);
    if (!_searching) {
      context.read<MoviesBloc>().add(const SearchChanged(''));
    }
  }

  Future<void> _refresh() {
    final bloc = context.read<MoviesBloc>()..add(const MoviesRequested());
    return bloc.stream.firstWhere((s) => s.status != MoviesStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MoviesBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie List'),
        actions: [
          IconButton(
            tooltip: _searching ? 'Close search' : 'Search',
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: BlocConsumer<MoviesBloc, MoviesState>(
              // A failed refresh keeps the old list, so tell the user instead.
              listenWhen: (previous, current) =>
                  current.status == MoviesStatus.failure &&
                  current.movies.isNotEmpty,
              listener: (context, state) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(state.failure!.message)),
                  );
              },
              builder: (context, state) {
                // Filtering walks the whole list, so do it once per state.
                final visible = state.visibleMovies;
                // "Totals = 0" while the first load is still running would be a lie.
                final hasLoaded =
                    state.status == MoviesStatus.success ||
                    state.movies.isNotEmpty;
                return Column(
                  children: [
                    if (_searching)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: SearchField(
                          onChanged: (value) => bloc.add(SearchChanged(value)),
                        ),
                      ),
                    Expanded(
                      child: _DismissKeyboardOnTouch(
                        child: Column(
                          children: [
                            _FilterHeader(
                              total: hasLoaded ? visible.length : null,
                            ),
                            RatingChips(
                              selected: state.category,
                              onSelected: (category) =>
                                  bloc.add(RatingSelected(category)),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: _Content(
                                state: state,
                                visible: visible,
                                onRefresh: _refresh,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Closes the keyboard as soon as the user touches anything but the search field.
///
/// Flutter's own `keyboardDismissBehavior` only fires when the list actually
/// moves, so it misses a list too short to scroll, the header and chips, and
/// the empty message. A raw pointer listener doesn't depend on any of that.
class _DismissKeyboardOnTouch extends StatelessWidget {
  const _DismissKeyboardOnTouch({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}

class _FilterHeader extends StatelessWidget {
  const _FilterHeader({required this.total});

  final int? total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text('Filter by Rating', style: style)),
          const SizedBox(width: 8),
          if (total != null)
            Flexible(
              child: Text(
                'Totals = $total',
                style: style,
                textAlign: TextAlign.end,
              ),
            ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.state,
    required this.visible,
    required this.onRefresh,
  });

  final MoviesState state;
  final List<Movie> visible;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final noData = state.movies.isEmpty;

    if (noData && state.status == MoviesStatus.failure) {
      return ErrorView(
        message: state.failure!.message,
        onRetry: () => context.read<MoviesBloc>().add(const MoviesRequested()),
      );
    }
    if (noData &&
        (state.status == MoviesStatus.loading ||
            state.status == MoviesStatus.initial)) {
      return const Center(child: CircularProgressIndicator());
    }

    // The list stays mounted when nothing matches so pull-to-refresh still works.
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Stack(
        children: [
          ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            // The list runs under the home indicator, so keep the last row clear.
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final movie = visible[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MovieCard(
                  movie: movie,
                  onTap: () => _openDetail(context, movie),
                ),
              );
            },
          ),
          if (visible.isEmpty) const _EmptyView(),
        ],
      ),
    );
  }
}

void _openDetail(BuildContext context, Movie movie) {
  FocusManager.instance.primaryFocus?.unfocus();
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => MovieDetailScreen(movie: movie)),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 40, color: colors.onSurfaceVariant),
          const SizedBox(height: 12),
          const Text('No movies found'),
        ],
      ),
    );
  }
}
