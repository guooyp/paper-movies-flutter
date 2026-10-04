import 'package:flutter/material.dart';

import '../../domain/entities/rating_category.dart';

class RatingChips extends StatelessWidget {
  const RatingChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final RatingCategory selected;
  final ValueChanged<RatingCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: MediaQuery.textScalerOf(context).scale(40),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: RatingCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = RatingCategory.values[index];
          return ChoiceChip(
            label: Text(category.name),
            selected: category == selected,
            showCheckmark: false,
            side: BorderSide(
              color: category == selected
                  ? colors.primary
                  : colors.outlineVariant,
            ),
            onSelected: (_) => onSelected(category),
          );
        },
      ),
    );
  }
}
