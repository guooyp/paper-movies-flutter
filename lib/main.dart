import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'core/app_bloc_observer.dart';
import 'core/theme/app_theme.dart';
import 'features/movies/data/datasources/movies_remote_datasource.dart';
import 'features/movies/data/repositories/movies_repository_impl.dart';
import 'features/movies/domain/usecases/get_movies.dart';
import 'features/movies/presentation/bloc/movies_bloc.dart';
import 'features/movies/presentation/pages/movies_screen.dart';

void main() {
  Bloc.observer = AppBlocObserver();

  final repository = MoviesRepositoryImpl(
    MoviesRemoteDataSource(client: http.Client()),
  );

  runApp(MoviesApp(getMovies: GetMovies(repository)));
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key, required this.getMovies});

  final GetMovies getMovies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      home: BlocProvider(
        create: (_) =>
            MoviesBloc(getMovies: getMovies)..add(const MoviesRequested()),
        child: const MoviesScreen(),
      ),
    );
  }
}
