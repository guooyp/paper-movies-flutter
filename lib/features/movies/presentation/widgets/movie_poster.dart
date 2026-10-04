import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/api_config.dart';

class MoviePoster extends StatelessWidget {
  const MoviePoster({
    super.key,
    required this.path,
    required this.width,
    required this.height,
    this.imageSize = 'w185',
    this.radius = 8,
  });

  final String? path;
  final double width;
  final double height;
  final String imageSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.movie_outlined, size: 24),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: path == null
          ? placeholder
          : CachedNetworkImage(
              imageUrl: ApiConfig.imageUrl(path!, size: imageSize),
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (_, _) => placeholder,
              errorWidget: (_, _, _) => placeholder,
            ),
    );
  }
}
