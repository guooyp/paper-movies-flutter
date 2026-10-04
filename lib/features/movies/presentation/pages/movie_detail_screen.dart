import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/format/language_name.dart';
import '../../../../core/format/release_date.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_poster.dart';

/// Shows what the list response already contains, so opening it costs no
/// request. Runtime and cast would need the /movie/{id} endpoint.
class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final Movie movie;

  static const _posterWidth = 112.0;
  static const _posterHeight = 168.0;
  // How far the poster hangs down over the page from the backdrop.
  static const _overlap = 64.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _scrollView(context),
          // Outside the scroll view so it stays reachable after scrolling.
          const Positioned(top: 0, left: 8, child: _BackButton()),
        ],
      ),
    );
  }

  Widget _scrollView(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 32 + bottomInset),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _Backdrop(path: movie.backdropPath),
                  Positioned(
                    left: 20,
                    bottom: -_overlap,
                    child: Hero(
                      tag: posterHeroTag(movie),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.surface, width: 3),
                        ),
                        child: MoviePoster(
                          path: movie.posterPath,
                          width: _posterWidth,
                          height: _posterHeight,
                          imageSize: 'w342',
                          radius: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Title sits beside the part of the poster that overhangs.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20 + _posterWidth + 16,
                  12,
                  20,
                  0,
                ),
                child: ConstrainedBox(
                  // Just enough to clear the part of the poster that hangs below
                  // the backdrop (minus the top padding above).
                  constraints: const BoxConstraints(minHeight: _overlap - 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatReleaseDate(movie.releaseDate) ??
                            'No release date',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Facts(movie: movie),
                    ..._genres(context),
                    const SizedBox(height: 28),
                    Text('Overview', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview ?? 'No synopsis available.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.55,
                        color: movie.overview == null
                            ? colors.onSurfaceVariant
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _genres(BuildContext context) {
    final names = genreNames(movie.genreIds);
    if (names.isEmpty) return const [];
    final colors = Theme.of(context).colorScheme;

    return [
      const SizedBox(height: 20),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final name in names)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Text(name, style: Theme.of(context).textTheme.labelLarge),
            ),
        ],
      ),
    ];
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fallback = ColoredBox(color: colors.primary.withValues(alpha: 0.14));

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (path == null)
            fallback
          else
            CachedNetworkImage(
              imageUrl: ApiConfig.imageUrl(path!, size: 'w780'),
              fit: BoxFit.cover,
              placeholder: (_, _) => fallback,
              errorWidget: (_, _, _) => fallback,
            ),
          // Fades the image into the page so the poster doesn't sit on a hard edge.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, colors.surface],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: IconButton.filled(
          tooltip: 'Back',
          style: IconButton.styleFrom(
            backgroundColor: colors.surface.withValues(alpha: 0.85),
            foregroundColor: colors.onSurface,
          ),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rated = movie.voteAverage > 0;

    final cells = [
      _Fact(
        label: 'Rating',
        value: rated ? movie.voteAverage.toStringAsFixed(1) : 'Not rated',
        leading: rated
            ? Icon(Icons.star_rounded, size: 18, color: colors.primary)
            : null,
      ),
      _Fact(
        label: 'Votes',
        value: NumberFormat.compact().format(movie.voteCount),
      ),
      _Fact(
        label: 'Language',
        value: languageName(movie.originalLanguage) ?? '-',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < cells.length; i++) ...[
              if (i > 0)
                VerticalDivider(width: 1, color: colors.outlineVariant),
              Expanded(child: cells[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, this.leading});

  final String label;
  final String value;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 2)],
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
