import 'package:intl/intl.dart';

final _isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// "2024-02-27" becomes "Feb 27, 2024". TMDB sometimes sends partial or odd
/// values, so anything that isn't a real calendar date is returned unchanged
/// rather than guessed at, and null or blank stays null.
String? formatReleaseDate(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return null;

  final match = _isoDate.firstMatch(text);
  if (match == null) return text;

  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);

  // DateTime rolls 2024-02-31 over to March, so check it round-trips.
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) return text;

  return DateFormat.yMMMd().format(date);
}
