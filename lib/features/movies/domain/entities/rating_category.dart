import 'package:equatable/equatable.dart';

class RatingCategory extends Equatable {
  const RatingCategory(this.name, this.minRating);

  final String name;

  /// A movie belongs to the category when its vote average is at least this.
  final double minRating;

  static const all = RatingCategory('All', 0);
  static const bad = RatingCategory('Bad', 4);
  static const good = RatingCategory('Good', 6);
  static const great = RatingCategory('Great', 8);
  static const recommend = RatingCategory('Recommend', 9);

  static const values = [all, bad, good, great, recommend];

  @override
  List<Object?> get props => [name, minRating];
}
