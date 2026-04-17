import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class SpecialistsEmptyView extends StatelessWidget {
  const SpecialistsEmptyView({
    required this.searchQuery,
    required this.hasActiveFilters,
    super.key,
  });

  final String searchQuery;
  final bool hasActiveFilters;

  // ── Derived display values ───────────────────────────────────────────────

  IconData get _icon =>
      hasActiveFilters ? Icons.filter_list_off : Icons.person_search;

  String get _title {
    if (hasActiveFilters) return 'No doctors match your filters';
    if (searchQuery.isNotEmpty) return 'No doctors found';
    return 'No doctors available';
  }

  String get _subtitle {
    if (hasActiveFilters) return 'Try adjusting your filter criteria';
    if (searchQuery.isNotEmpty) return 'Try a different search term';
    return 'Check back later for available doctors';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, size: 80, color: AppColors.lightText),
            const SizedBox(height: 16),
            Text(
              _title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.lightTextColor),
            ),
          ],
        ),
      ),
    );
  }
}