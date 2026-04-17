import 'package:flutter/material.dart';

class SlotScrollPeriodConfig {
  const SlotScrollPeriodConfig({
    required this.title,
    required this.slots,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<Map<String, dynamic>> slots;
  final IconData icon;
  final Color color;
}
