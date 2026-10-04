# Paper Movies

A Flutter app that lists popular movies from TMDB. You can filter the list with the rating chips and search by title. Tapping a movie opens a detail page.

There is also a web version in Angular: https://github.com/guooyp/paper-movies-web

## Run it

1. Copy `env.json.example` to `env.json` and put your TMDB API key in it.
2. `flutter pub get`
3. `flutter run --dart-define-from-file=env.json`

Run the tests with `flutter test`. GitHub Actions runs the formatter check, the analyzer and the tests on every push.

Tested with Flutter 3.47 on the iOS simulator and on an Android emulator (Pixel 9 Pro).

## Structure

I followed the folder layout from the brief, with a domain layer added:

```
lib/
  core/                 failures, config, theme
  features/movies/
    data/
      datasources/      the API service, the only code that uses http
      models/           MovieModel, parses the JSON
      repositories/     turns exceptions into failures
    domain/
      entities/         Movie, RatingCategory
      repositories/     repository interface
      usecases/         GetMovies, filterMovies
    presentation/
      bloc/             MoviesBloc
      pages/            movie list and movie detail screens
      widgets/          card, chips, search field, error view
```

## How it works

The screen asks `MoviesBloc` to load the movies. The bloc calls the `GetMovies` use case, which calls the repository, which calls the API service. The bloc keeps the full list it gets back, plus the search text and the selected rating.

The list on screen is worked out from those three things every time one of them changes. That is why filtering and searching never call the API again, and why the list can't get out of sync with the chips. The search is debounced by 300 ms inside the bloc, so it only filters once you stop typing.

## Decisions

**Rating filter.** The brief doesn't say if the rating is a minimum or a range. The reference screenshot shows 20 results under "Bad", which a range of 2 to 4 would not give, so I treat it as a minimum: Bad is 4 and above, Good 6, Great 8 and Recommend 9. The example data has "All" at 2. I set it to 0, because with 2 a movie with no votes disappears even when "All" is selected.

**Page 1 only.** The brief asks for page 1, and it wants search to work on the local list. With several pages, a search could only find movies from the pages already loaded, so a movie on page 3 would look like it doesn't exist. Paging properly would need search on the server.

**Failures instead of Either.** The repository throws a small set of failure types (no connection, server error, bad response). `Either` would work too, but it adds a dependency for a single call. The bloc also catches anything unexpected, so a bug can't leave the screen loading forever.

**No DI package.** The dependencies are created by hand in `main.dart`. With one screen, `get_it` or code generation would be more setup than code.

**Detail page.** It only uses what the list response already contains, so opening it makes no extra request. The response has genre ids and not names, so there is a small lookup table in the app. Runtime and cast would need another endpoint, and the brief doesn't ask for them.

**API key.** It is not committed. It comes from `env.json`, which is git-ignored, when you run the app. Anything inside a mobile app can be extracted, so a real app would call TMDB through its own backend.

## Error handling and edge cases

- No internet, a timeout, a non-200 response and a response that isn't the expected JSON each show an error message with a retry button.
- If a pull to refresh fails, the current list stays and a snackbar shows the error.
- A missing API key shows the same message as other errors, and the console says what is missing.
- A movie with no poster shows a placeholder. A missing release date shows "No release date". An empty title falls back to the original title.
- Dates are shown as "Feb 27, 2024". Anything that isn't a real date, like "2024-02-31", is shown as it came.
- A search or filter with no results shows "No movies found".
- The layout works with large text, in dark mode, and on tablets, where the content stays in a centred column.

## Tests

There are unit tests for the model, the API service, the repository, the filter, the bloc and the helpers, and widget tests for the screens (loading, error, empty, search, chips, refresh, detail page). I also ran the tests against a few deliberate bugs to check they fail when they should.
